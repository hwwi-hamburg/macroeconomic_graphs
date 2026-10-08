# Generate graph-module metadata

Use the prompt below with an AI coding assistant. Replace `<GRAPH_FILE>` with
the repository-relative path to the graph implementation.

```text
Inspect `<GRAPH_FILE>` and the plotting functions it defines. Then generate the
graph-module metadata needed by this project.

Project rules:

- Metadata belongs at the bottom of the same graph file in `.graph_specs`.
- Create one entry for every distinct graph output implemented by the file.
- Every entry must contain these required fields:
  - `id`: unique, stable, descriptive snake_case identifier.
  - `category`: one of `GDP`, `Employment`, `Prices`, or `Trade`.
  - `label`: concise English label suitable for the CLI menu.
  - `render`: a zero-argument function that renders German and English outputs.
- Entries may additionally contain these optional fields:
  - `source`: the data source in English, taken from the English caption
    without the "Data source:" prefix. Omit it if it would be identical to the
    caption, because the graph lists fall back to the caption.
  - `notes`: short remarks for users of the graph. Only add notes that follow
    from the code (e.g. seasonal adjustment, rebasing); otherwise omit them.
- Use `file.path(OUT_DIR, "<Category> graphs/German labeling")` and the
  equivalent English directory. Preserve the capitalization already used by
  other graphs in the same category.
- Call the graph's existing plotting function; do not duplicate fetching,
  transformation, or plotting logic inside `render`.
- Pass German labels, captions, decimal marks, and thousands separators to the
  German call. Pass their English equivalents to the English call.
- Use `render_graph()` for every output.
- Preserve established output filename stems found in the graph file's existing
  code or `.graph_specs` metadata.
- Do not invent data-series codes, table IDs, function arguments, or output
  names. Flag missing information instead.
- Do not modify unrelated code.
- Do not add an entry for a helper function whose output is not independently
  rendered.
- Check the proposed IDs against all existing `.graph_specs` and report any
  collision.

Append this footer after `.graph_specs`:

if (!exists("auto_run_graph_file", mode = "function")) source("src/graph_modules.R")
auto_run_graph_file("<GRAPH_FILE>", .graph_specs)

Return:

1. The complete `.graph_specs <- list(...)` block and footer as valid R code.
2. A short list of assumptions or unresolved information, if any.

Before finishing, parse-check the resulting graph file and run
`discover_graphs()` to validate required fields and unique IDs. Do not fetch
external data or render graphs unless explicitly asked.
```

## Example request

```text
Use prompts/generate_graph_metadata.md to generate metadata for
src/graphs/gdp/my_new_graph.R and apply it to the file.
```
