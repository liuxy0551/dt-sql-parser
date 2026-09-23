## Benchmark

### Language
HiveSQL

### Report Time
2026/9/23 13:52:26

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
| Query Collection|           getAllTokens          |  1015  |       246      | 
| Query Collection|             validate            |  1015  |       226      | 
|   Update Table  |           getAllTokens          |  1011  |       126      | 
|   Update Table  |             validate            |  1011  |       130      | 
|  Insert Columns |           getAllTokens          |  1001  |       212      | 
|  Insert Columns |             validate            |  1001  |       209      | 
|   Create Table  |           getAllTokens          |  1002  |       18       | 
|   Create Table  |             validate            |  1002  |       18       | 
|    Split SQL    |       splitSQLByStatement       |  1001  |       71       | 
| Collect Entities|          getAllEntities         |  1066  |       358      | 
|    Suggestion   |   getSuggestionAtCaretPosition  |  1066  |       207      | 
|Collect Semantics|getSemanticContextAtCaretPosition|  1015  |       318      | 


