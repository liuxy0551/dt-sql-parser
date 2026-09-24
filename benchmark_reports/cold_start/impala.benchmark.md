## Benchmark

### Language
ImpalaSQL

### Report Time
2026/9/24 14:40:09

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
| Query Collection|           getAllTokens          |  1015  |       93       | 
| Query Collection|             validate            |  1015  |       128      | 
|   Update Table  |           getAllTokens          |  1011  |       129      | 
|   Update Table  |             validate            |  1011  |       104      | 
|  Insert Columns |           getAllTokens          |  1001  |       149      | 
|  Insert Columns |             validate            |  1001  |       146      | 
|   Create Table  |           getAllTokens          |  1002  |       28       | 
|   Create Table  |             validate            |  1002  |       38       | 
|    Split SQL    |       splitSQLByStatement       |  1001  |       158      | 
| Collect Entities|          getAllEntities         |  1066  |       174      | 
|    Suggestion   |   getSuggestionAtCaretPosition  |  1066  |       116      | 
|Collect Semantics|getSemanticContextAtCaretPosition|  1015  |       109      | 


