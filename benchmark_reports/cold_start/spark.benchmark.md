## Benchmark

### Language
SparkSQL

### Report Time
2024/12/26 17:54:42

### Device
macOS 14.7.2
(8) arm64 Apple M3
16.00 GB

### Version
`nodejs`: v18.20.3
`dt-sql-parser`: v4.1.0-beta.0
`antlr4-c3`: v3.3.7
`antlr4ng`: v2.0.11

### Running Mode
Cold Start

### Report
| Benchmark Name |         Method Name        |SQL Rows|Average Time(ms)|Last Cost Time(ms)|All Times(ms)|  Loops | 
|----------------|----------------------------|--------|----------------|------------------|-------------|--------| 
|Query Collection|        getAllTokens        |  1015  |       243      |                  |339,242,248,240,243|    5   | 
|Query Collection|          validate          |  1015  |       249      |                  |249,245,255,245,272|    5   | 
|  Update Table  |        getAllTokens        |  1011  |       221      |                  |251,222,220,223,218|    5   | 
|  Update Table  |          validate          |  1011  |       225      |                  |226,222,228,223,268|    5   | 
| Insert Columns |        getAllTokens        |  1001  |       198      |                  |201,194,200,213,183|    5   | 
| Insert Columns |          validate          |  1001  |       190      |                  |185,182,190,192,192|    5   | 
|  Create Table  |        getAllTokens        |  1002  |       27       |                  |28,27,26,27,32|    5   | 
|  Create Table  |          validate          |  1002  |       27       |                  |27,28,27,28,27|    5   | 
|    Split SQL   |     splitSQLByStatement    |  1001  |       102      |                  |104,102,99,101,102|    5   | 
|Collect Entities|       getAllEntities       |  1066  |       258      |                  |275,259,258,257,257|    5   | 
|   Suggestion   |getSuggestionAtCaretPosition|  1066  |       244      |                  |244,245,245,240,317|    5   | 


<input type="hidden" value='[{"name":"Query Collection","avgTime":243,"costTimes":[339,242,248,240,243],"loopTimes":5,"rows":1015,"type":"getAllTokens"},{"name":"Query Collection","avgTime":249,"costTimes":[249,245,255,245,272],"loopTimes":5,"rows":1015,"type":"validate"},{"name":"Update Table","avgTime":221,"costTimes":[251,222,220,223,218],"loopTimes":5,"rows":1011,"type":"getAllTokens"},{"name":"Update Table","avgTime":225,"costTimes":[226,222,228,223,268],"loopTimes":5,"rows":1011,"type":"validate"},{"name":"Insert Columns","avgTime":198,"costTimes":[201,194,200,213,183],"loopTimes":5,"rows":1001,"type":"getAllTokens"},{"name":"Insert Columns","avgTime":190,"costTimes":[185,182,190,192,192],"loopTimes":5,"rows":1001,"type":"validate"},{"name":"Create Table","avgTime":27,"costTimes":[28,27,26,27,32],"loopTimes":5,"rows":1002,"type":"getAllTokens"},{"name":"Create Table","avgTime":27,"costTimes":[27,28,27,28,27],"loopTimes":5,"rows":1002,"type":"validate"},{"name":"Split SQL","avgTime":102,"costTimes":[104,102,99,101,102],"loopTimes":5,"rows":1001,"type":"splitSQLByStatement"},{"name":"Collect Entities","avgTime":258,"costTimes":[275,259,258,257,257],"loopTimes":5,"rows":1066,"type":"getAllEntities"},{"name":"Suggestion","avgTime":244,"costTimes":[244,245,245,240,317],"loopTimes":5,"rows":1066,"type":"getSuggestionAtCaretPosition"}]'/>
