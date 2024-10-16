import { CharStream, CommonTokenStream, Token } from 'antlr4ng';
import { CandidatesCollection } from 'antlr4-c3';
import { MySqlLexer } from '../../lib/mysql/MySqlLexer';
import { MySqlParser, ProgramContext } from '../../lib/mysql/MySqlParser';
import { BasicSQL } from '../common/basicSQL';
import { Suggestions, EntityContextType, SyntaxSuggestion } from '../common/types';
import { StmtContextType } from '../common/entityCollector';
import { MysqlSplitListener } from './mysqlSplitListener';
import { MySqlEntityCollector } from './mysqlEntityCollector';
import { MysqlErrorListener } from './mysqlErrorListener';
import { ErrorListener } from '../common/parseErrorListener';

export { MySqlEntityCollector, MysqlSplitListener };

export class MySQL extends BasicSQL<MySqlLexer, ProgramContext, MySqlParser> {
    protected createLexerFromCharStream(charStreams: CharStream): MySqlLexer {
        return new MySqlLexer(charStreams);
    }

    protected createParserFromTokenStream(tokenStream: CommonTokenStream): MySqlParser {
        return new MySqlParser(tokenStream);
    }

    protected preferredRules: Set<number> = new Set([
        MySqlParser.RULE_databaseName,
        MySqlParser.RULE_databaseNameCreate,
        MySqlParser.RULE_tableName,
        MySqlParser.RULE_tableNameCreate,
        MySqlParser.RULE_viewName,
        MySqlParser.RULE_viewNameCreate,
        MySqlParser.RULE_functionName,
        MySqlParser.RULE_functionNameCreate,
        MySqlParser.RULE_columnName,
        MySqlParser.RULE_columnNameCreate,
    ]);

    protected get splitListener() {
        return new MysqlSplitListener();
    }

    protected createErrorListener(_errorListener: ErrorListener) {
        return new MysqlErrorListener(_errorListener, this.preferredRules, this.locale);
    }

    protected createEntityCollector(input: string, caretTokenIndex?: number) {
        return new MySqlEntityCollector(input, caretTokenIndex);
    }

    protected processCandidates(
        candidates: CandidatesCollection,
        allTokens: Token[],
        caretTokenIndex: number,
        tokenIndexOffset: number
    ): Suggestions<Token> {
        const originalSyntaxSuggestions: SyntaxSuggestion<Token>[] = [];
        const keywords: string[] = [];

        for (const candidate of candidates.rules) {
            const [ruleType, candidateRule] = candidate;
            const startTokenIndex = candidateRule.startTokenIndex + tokenIndexOffset;
            const tokenRanges = allTokens.slice(
                startTokenIndex,
                caretTokenIndex + tokenIndexOffset + 1
            );

            let syntaxContextType: EntityContextType | StmtContextType | undefined = void 0;
            switch (ruleType) {
                case MySqlParser.RULE_databaseName: {
                    syntaxContextType = EntityContextType.DATABASE;
                    break;
                }
                case MySqlParser.RULE_databaseNameCreate: {
                    syntaxContextType = EntityContextType.DATABASE_CREATE;
                    break;
                }
                case MySqlParser.RULE_tableName: {
                    syntaxContextType = EntityContextType.TABLE;
                    break;
                }
                case MySqlParser.RULE_tableNameCreate: {
                    syntaxContextType = EntityContextType.TABLE_CREATE;
                    break;
                }
                case MySqlParser.RULE_viewName: {
                    syntaxContextType = EntityContextType.VIEW;
                    break;
                }
                case MySqlParser.RULE_viewNameCreate: {
                    syntaxContextType = EntityContextType.VIEW_CREATE;
                    break;
                }
                case MySqlParser.RULE_functionName: {
                    syntaxContextType = EntityContextType.FUNCTION;
                    break;
                }
                case MySqlParser.RULE_functionNameCreate: {
                    syntaxContextType = EntityContextType.FUNCTION_CREATE;
                    break;
                }
                case MySqlParser.RULE_columnName: {
                    syntaxContextType = EntityContextType.COLUMN;
                    break;
                }
                case MySqlParser.RULE_columnNameCreate: {
                    syntaxContextType = EntityContextType.COLUMN_CREATE;
                    break;
                }
                default:
                    break;
            }

            if (syntaxContextType) {
                originalSyntaxSuggestions.push({
                    syntaxContextType,
                    wordRanges: tokenRanges,
                });
            }
        }

        for (const candidate of candidates.tokens) {
            const symbolicName = this._parser.vocabulary.getSymbolicName(candidate[0]);
            const displayName = this._parser.vocabulary.getDisplayName(candidate[0]);
            if (displayName && symbolicName && symbolicName.startsWith('KW_')) {
                const keyword =
                    displayName.startsWith("'") && displayName.endsWith("'")
                        ? displayName.slice(1, -1)
                        : displayName;
                keywords.push(keyword);
            }
        }

        return {
            syntax: originalSyntaxSuggestions,
            keywords,
        };
    }
}
