source("src/bootstrap.R")
.graphs <- discover_graphs()

for (g in .graphs) {
  if (g$category == "GDP") {
    tryCatch(
      with_graph_context(g$id, g$render()),
      error = function(e) message("SKIPPED ", g$id, ": ", conditionMessage(e))
    )
  }
}

write_graph_overview(.graphs)
