## Benchmark

### Language
FlinkSQL

### Report Time
2026/9/24 10:14:35

### Device
macOS 15.7.9
(8) arm64 Apple M3
16.00 GB

### Version
`nodejs`: v22.23.1
`dt-sql-parser`: v4.5.1
`antlr4-c3`: v3.3.7
`antlr4ng`: v2.0.11

### Running Mode
Cold Start

### Report
|  Benchmark Name |           Method Name           |SQL Rows|Average Time(ms)| 
|-----------------|---------------------------------|--------|----------------| 
| Query Collection|           getAllTokens          |  1015  |       298      | 
| Query Collection|             validate            |  1015  |       301      | 
|  Insert Columns |           getAllTokens          |  1001  |       59       | 
|  Insert Columns |             validate            |  1001  |       58       | 
|   Create Table  |           getAllTokens          |  1004  |       19       | 
|   Create Table  |             validate            |  1004  |       19       | 
|    Split SQL    |       splitSQLByStatement       |   999  |       47       | 
| Collect Entities|          getAllEntities         |  1056  |       199      | 
|    Suggestion   |   getSuggestionAtCaretPosition  |  1056  |       240      | 
|Collect Semantics|getSemanticContextAtCaretPosition|  1015  |       323      | 


