export const meta = {
  name: 'adaptive-explore',
  description: '対象ファイル群の種類と複雑さを先に判定し、複雑度に応じた並列数で読み取り調査する',
  whenToUse: '複数ファイルを調査したいが、内容の複雑さに応じて並列度を自動で変えたいとき。args にファイルパスの配列、または調査対象を表す文字列を渡す。',
  phases: [
    { title: 'Classify', detail: '全ファイルを軽く分類し複雑度を判定' },
    { title: 'Explore', detail: '複雑度から決めた並列数で読み取り調査' },
  ],
}

// args: ファイルパスの配列、または対象を説明する文字列。未指定なら全体をざっと見る指示にする。
const target = Array.isArray(args)
  ? args.join('\n')
  : (typeof args === 'string' && args ? args : 'リポジトリ全体の主要なソースファイル')

phase('Classify')

const CLASSIFY_SCHEMA = {
  type: 'object',
  required: ['items'],
  properties: {
    items: {
      type: 'array',
      items: {
        type: 'object',
        required: ['path', 'kind', 'complexity'],
        properties: {
          path: { type: 'string' },
          kind: { type: 'string', description: '例: code / config / doc / test / data' },
          complexity: { type: 'string', enum: ['simple', 'moderate', 'complex'] },
        },
      },
    },
  },
}

const cls = await agent(
  `次の対象を調査する前段として、各ファイルを軽く開いて分類してほしい。\n` +
    `中身を精読せず、種類(kind)と複雑さ(complexity: simple/moderate/complex)だけ判定する。\n` +
    `complex の目安: 長い・分岐や状態が多い・他と密結合・設計判断が絡む。\n` +
    `simple の目安: 短い・定型・設定値の羅列・自明。\n\n対象:\n${target}`,
  { phase: 'Classify', schema: CLASSIFY_SCHEMA },
)

const items = (cls?.items ?? []).filter((it) => it && it.path)
if (items.length === 0) {
  return { error: '分類対象が見つからなかった', target }
}

// 複雑度 → 1ファイルあたりの「読みの重さ」。重いほど少数を深く、軽いほど多数を一気に。
// ponytail: 3段の固定テーブル。段階を増やしたくなったら weight を足すだけ。
const WEIGHT = { simple: 1, moderate: 2, complex: 4 }
const totalWeight = items.reduce((s, it) => s + (WEIGHT[it.complexity] ?? 2), 0)
const avg = totalWeight / items.length

// 平均が重いほど並列数を絞る(深く読ませる)。軽いほど広げる。上限はランタイム側の同時実行キャップに任せる。
const parallelism = Math.max(1, Math.min(items.length, Math.round(items.length / avg)))

log(`分類 ${items.length} 件 / 平均複雑度 ${avg.toFixed(1)} → 並列度 ${parallelism}`)

phase('Explore')

const FIND_SCHEMA = {
  type: 'object',
  required: ['path', 'summary'],
  properties: {
    path: { type: 'string' },
    summary: { type: 'string', description: 'そのファイルの役割と要点。path:line 参照を含める' },
  },
}

// parallelism をバッチサイズとして items を分割し、バッチごとに同時起動。
// (ランタイムの同時実行キャップ内で動くので、これは「1度に投げる束の大きさ」の制御)
const results = []
for (let i = 0; i < items.length; i += parallelism) {
  const batch = items.slice(i, i + parallelism)
  const got = await parallel(
    batch.map((it) => () =>
      agent(`次のファイルを読み、役割と要点を簡潔にまとめる。中身を全部貼らず結論と path:line を返す。\nfile: ${it.path}\nkind: ${it.kind} / complexity: ${it.complexity}`, {
        label: `explore:${it.path}`,
        phase: 'Explore',
        agentType: 'explorer',
        schema: FIND_SCHEMA,
      }),
    ),
  )
  results.push(...got.filter(Boolean))
}

return { parallelism, avgComplexity: Number(avg.toFixed(2)), count: results.length, findings: results }
