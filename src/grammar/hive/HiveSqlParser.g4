/**
 Licensed to the Apache Software Foundation (ASF) under one or more contributor license agreements.
 See the NOTICE file distributed with this work for additional information regarding copyright
 ownership. The ASF licenses this file to You under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy of the
 License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software distributed under the License
 is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 implied. See the License for the specific language governing permissions and limitations under the
 License.
 */

/**
 * This file is an adaptation of antlr/grammars-v4's sql/hive/v4/HiveParser.g4 grammar. Reference:
 * https://github.com/antlr/grammars-v4/blob/master/sql/hive/v4/HiveParser.g4
 */

// $antlr-format alignTrailingComments true, columnLimit 150, minEmptyLines 1, maxEmptyLinesToKeep 1, reflowComments false, useTab false
// $antlr-format allowShortRulesOnASingleLine false, allowShortBlocksOnASingleLine true, alignSemicolons hanging, alignColons hanging
// $antlr-format spaceBeforeAssignmentOperators false, keepEmptyLinesAtTheStartOfBlocks true

parser grammar HiveSqlParser;

options
{
    tokenVocab=HiveSqlLexer;
    caseInsensitive= true;
    superClass=SQLParserBase;
}

@header {
import { SQLParserBase } from '../SQLParserBase';
}

program
    : statement* EOF
    ;

// starting rule
statement
    : (explainStatement | execStatement) SEMICOLON?
    ;

explainStatement
    : KW_EXPLAIN (explainOption* execStatement | KW_REWRITE queryStatementExpression)
    ;

explainOption
    : KW_EXTENDED
    | KW_FORMATTED
    | KW_DEPENDENCY
    | KW_CBO (KW_COST | KW_JOINCOST)?
    | KW_LOGICAL
    | KW_AUTHORIZATION
    | KW_ANALYZE
    | KW_REOPTIMIZATION
    | KW_LOCKS
    | KW_AST
    | KW_VECTORIZATION vectorizationOnly? vectorizatonDetail?
    | KW_DEBUG
    | KW_DDL
    ;

vectorizationOnly
    : KW_ONLY
    ;

vectorizatonDetail
    : KW_SUMMARY
    | KW_OPERATOR
    | KW_EXPRESSION
    | KW_DETAIL
    ;

execStatement
    : queryStatementExpression
    | loadStatement
    | exportStatement
    | importStatement
    | replDumpStatement
    | replLoadStatement
    | replStatusStatement
    | ddlStatement
    | deleteStatement
    | updateStatement
    | sqlTransactionStatement
    | mergeStatement
    | prepareStatement
    | executeStatement
    | setConfigPropertiesStatement
    ;

loadStatement
    : KW_LOAD KW_DATA KW_LOCAL? KW_INPATH StringLiteral KW_OVERWRITE? KW_INTO KW_TABLE tableOrPartition inputFileFormat?
    ;

dropPartitionsIgnoreClause
    : KW_IGNORE KW_PROTECTION
    ;

replicationClause
    : KW_FOR KW_METADATA? KW_REPLICATION LPAREN StringLiteral RPAREN
    ;

exportStatement
    : KW_EXPORT KW_TABLE tableOrPartition KW_TO StringLiteral replicationClause?
    ;

importStatement
    : KW_IMPORT (KW_EXTERNAL? KW_TABLE tableOrPartition)? KW_FROM path=StringLiteral tableLocation?
    ;

replDumpStatement
    : KW_REPL KW_DUMP dbPolicy=replDbPolicy (KW_REPLACE oldDbPolicy=replDbPolicy)? (
        KW_WITH replConf=replConfigs
    )?
    ;

replDbPolicy
    : dbName=dbSchemaName (DOT tablePolicy=replTableLevelPolicy)?
    ;

replLoadStatement
    : KW_REPL KW_LOAD sourceDbPolicy=replDbPolicy (KW_INTO dbName=dbSchemaName)? (
        KW_WITH replConf=replConfigs
    )?
    ;

replConfigs
    : LPAREN replConfigsList RPAREN
    ;

replConfigsList
    : keyValueProperty (COMMA keyValueProperty)*
    ;

replTableLevelPolicy
    : replTablesIncludeList=StringLiteral (DOT replTablesExcludeList=StringLiteral)?
    ;

replStatusStatement
    : KW_REPL KW_STATUS dbName=dbSchemaName (KW_WITH replConf=replConfigs)?
    ;

ddlStatement
    : createDatabaseStatement
    | switchDatabaseStatement
    | dropDatabaseStatement
    | createTableStatement
    | dropTableStatement
    | truncateTableStatement
    | alterStatement
    | descStatement
    | showStatement
    | metastoreCheck
    | createViewStatement
    | createMaterializedViewStatement
    | createScheduledQueryStatement
    | alterScheduledQueryStatement
    | dropScheduledQueryStatement
    | dropViewStatement
    | dropMaterializedViewStatement
    | createFunctionStatement
    | createMacroStatement
    | dropFunctionStatement
    | reloadFunctionsStatement
    | dropMacroStatement
    | createIndexStatement
    | dropIndexStatement
    | analyzeStatement
    | lockStatement
    | unlockStatement
    | lockDatabase
    | unlockDatabase
    | createRoleStatement
    | dropRoleStatement
    | grantPrivileges
    | revokePrivileges
    | showGrants
    | showRoleGrants
    | showRolePrincipals
    | showRoles
    | grantRole
    | revokeRole
    | setRole
    | showCurrentRole
    | abortTransactionStatement
    | abortCompactionStatement
    | killQueryStatement
    | resourcePlanDdlStatements
    | createDataConnectorStatement
    | dropDataConnectorStatement
    ;

ifExists
    : KW_IF KW_EXISTS
    ;

restrictOrCascade
    : KW_RESTRICT
    | KW_CASCADE
    ;

ifNotExists
    : KW_IF KW_NOT KW_EXISTS
    ;

force
    : KW_FORCE
    ;

rewriteEnabled
    : enable KW_REWRITE
    ;

rewriteDisabled
    : disable KW_REWRITE
    ;

storedAsDirs
    : KW_STORED KW_AS KW_DIRECTORIES
    ;

orReplace
    : KW_OR KW_REPLACE
    ;

createDatabaseStatement
    : KW_CREATE KW_REMOTE? db_schema ifNotExists? name=dbSchemaNameCreate databaseComment? dbLocation? dbManagedLocation? (
        KW_WITH KW_DBPROPERTIES dbprops=dbProperties
    )?
    | KW_CREATE KW_REMOTE db_schema ifNotExists? name=dbSchemaNameCreate databaseComment? dbConnectorName (
        KW_WITH KW_DBPROPERTIES dbprops=dbProperties
    )?
    ;

dbLocation
    : KW_LOCATION locn=StringLiteral
    ;

dbManagedLocation
    : KW_MANAGEDLOCATION locn=StringLiteral
    ;

dbProperties
    : LPAREN dbPropertiesList RPAREN
    ;

dbPropertiesList
    : keyValueProperty (COMMA keyValueProperty)*
    ;

dbConnectorName
    : KW_USING dcName=dbSchemaName
    ;

switchDatabaseStatement
    : KW_USE dbSchemaName
    ;

dropDatabaseStatement
    : KW_DROP db_schema ifExists? dbSchemaName restrictOrCascade?
    ;

databaseComment
    : KW_COMMENT comment=StringLiteral
    ;

truncateTableStatement
    : KW_TRUNCATE KW_TABLE? tablePartitionPrefix (KW_COLUMNS LPAREN columnNameList RPAREN)? force?
    ;

dropTableStatement
    : KW_DROP KW_TABLE ifExists? tableName KW_PURGE? replicationClause?
    ;

inputFileFormat
    : KW_INPUTFORMAT inFmt=StringLiteral KW_SERDE serdeCls=StringLiteral
    ;

tabTypeExpr
    : id_ (DOT id_)? (id_ (DOT (KW_ELEM_TYPE | KW_KEY_TYPE | KW_VALUE_TYPE | id_))*)?
    ;

partTypeExpr
    : tabTypeExpr partitionSpec?
    ;

tabPartColTypeExpr
    : tableOrView partitionSpec? extColumnName?
    ;

descStatement
    : (KW_DESCRIBE | KW_DESC) (
        db_schema KW_EXTENDED? dbName=dbSchemaName
        | KW_DATACONNECTOR KW_EXTENDED? dcName=dbSchemaName
        | KW_FUNCTION KW_EXTENDED? name=functionNameForDDL
        | (descOptions=KW_FORMATTED | descOptions=KW_EXTENDED) parttype=tabPartColTypeExpr
        | parttype=tabPartColTypeExpr
    )
    ;

analyzeStatement
    : KW_ANALYZE KW_TABLE parttype=tableOrPartition (
        KW_COMPUTE KW_STATISTICS (
            noscan=KW_NOSCAN
            | KW_FOR KW_COLUMNS statsColumnName=columnNameList?
        )?
        | KW_CACHE KW_METADATA
    )
    ;

from_in
    : KW_FROM
    | KW_IN
    ;

db_schema
    : KW_DATABASE
    | KW_SCHEMA
    ;

showStatement
    : KW_SHOW (KW_DATABASES | KW_SCHEMAS) (KW_LIKE showStmtIdentifier)?
    | KW_SHOW isExtended=KW_EXTENDED? KW_TABLES (from_in db_name=dbSchemaName)? filter=showTablesFilterExpr?
    | KW_SHOW KW_VIEWS (from_in db_name=dbSchemaName)? (
        KW_LIKE showStmtIdentifier
        | showStmtIdentifier
    )?
    | KW_SHOW KW_MATERIALIZED KW_VIEWS (from_in db_name=dbSchemaName)? (
        KW_LIKE showStmtIdentifier
        | showStmtIdentifier
    )?
    | KW_SHOW KW_SORTED? KW_COLUMNS from_in tableOrView (from_in db_name=dbSchemaName)? (
        KW_LIKE showStmtIdentifier
        | showStmtIdentifier
    )?
    | KW_SHOW KW_FUNCTIONS (KW_LIKE functionNameForDDL)?
    | KW_SHOW KW_PARTITIONS tabOrViewName=tableOrView partitionSpec? whereClause? orderByClause? limitClause?
    | KW_SHOW KW_CREATE (db_schema db_name=dbSchemaName | KW_TABLE tabName=tableName)
    | KW_SHOW KW_TABLE KW_EXTENDED (from_in db_name=dbSchemaName)? KW_LIKE showStmtIdentifier partitionSpec?
    | KW_SHOW KW_TBLPROPERTIES tableName (LPAREN prptyName=StringLiteral RPAREN)?
    | KW_SHOW KW_LOCKS (
        db_schema dbName=dbSchemaName isExtended=KW_EXTENDED?
        | parttype=partTypeExpr? isExtended=KW_EXTENDED?
    )
    | KW_SHOW KW_COMPACTIONS (
        compactionId
        | db_schema dbName=dbSchemaName compactionPool? compactionType? compactionStatus? orderByClause? limitClause?
        | parttype=partTypeExpr? compactionPool? compactionType? compactionStatus? orderByClause? limitClause?
    )
    | KW_SHOW KW_TRANSACTIONS
    | KW_SHOW KW_CONF StringLiteral
    | KW_SHOW KW_RESOURCE (KW_PLAN rp_name=id_ | KW_PLANS)
    | KW_SHOW KW_DATACONNECTORS
    | KW_SHOW KW_FORMATTED? (KW_INDEX | KW_INDEXES) KW_ON tableName (from_in dbSchemaName)?
    ;

showTablesFilterExpr
    : KW_WHERE id_ EQUAL StringLiteral
    | KW_LIKE showStmtIdentifier
    | showStmtIdentifier
    ;

lockStatement
    : KW_LOCK KW_TABLE tableName partitionSpec? lockMode
    ;

lockDatabase
    : KW_LOCK db_schema dbName=dbSchemaName lockMode
    ;

lockMode
    : KW_SHARED
    | KW_EXCLUSIVE
    ;

unlockStatement
    : KW_UNLOCK KW_TABLE tableName partitionSpec?
    ;

unlockDatabase
    : KW_UNLOCK db_schema dbName=dbSchemaName
    ;

createRoleStatement
    : KW_CREATE KW_ROLE roleName=id_
    ;

dropRoleStatement
    : KW_DROP KW_ROLE roleName=id_
    ;

grantPrivileges
    : KW_GRANT privList=privilegeList privilegeObject? KW_TO principalSpecification withGrantOption?
    ;

revokePrivileges
    : KW_REVOKE grantOptionFor? privilegeList privilegeObject? KW_FROM principalSpecification
    ;

grantRole
    : KW_GRANT KW_ROLE? id_ (COMMA id_)* KW_TO principalSpecification withAdminOption?
    ;

revokeRole
    : KW_REVOKE adminOptionFor? KW_ROLE? id_ (COMMA id_)* KW_FROM principalSpecification
    ;

showRoleGrants
    : KW_SHOW KW_ROLE KW_GRANT principalName
    ;

showRoles
    : KW_SHOW KW_ROLES
    ;

showCurrentRole
    : KW_SHOW KW_CURRENT KW_ROLES
    ;

setRole
    : KW_SET KW_ROLE (all=KW_ALL | none=KW_NONE | id_)
    ;

showGrants
    : KW_SHOW KW_GRANT principalName? (KW_ON privilegeIncludeColObject)?
    ;

showRolePrincipals
    : KW_SHOW KW_PRINCIPALS roleName=id_
    ;

privilegeIncludeColObject
    : KW_ALL
    | privObjectCols
    ;

privilegeObject
    : KW_ON privObject
    ;

/**
database or table type. Type is optional, default type is table
*/
privObject
    : db_schema dbSchemaName
    | KW_TABLE? tableName partitionSpec?
    | KW_URI path=StringLiteral
    | KW_SERVER id_
    ;

privObjectCols
    : db_schema dbSchemaName
    | KW_TABLE? tableName (LPAREN cols=columnNameList RPAREN)? partitionSpec?
    | KW_URI path=StringLiteral
    | KW_SERVER id_
    ;

privilegeList
    : privlegeDef (COMMA privlegeDef)*
    ;

privlegeDef
    : privilegeType (LPAREN cols=columnNameList RPAREN)?
    ;

privilegeType
    : KW_ALL
    | KW_ALTER
    | KW_UPDATE
    | KW_CREATE
    | KW_DROP
    | KW_INDEX
    | KW_LOCK
    | KW_SELECT
    | KW_SHOW_DATABASE
    | KW_INSERT
    | KW_DELETE
    ;

principalSpecification
    : principalName (COMMA principalName)*
    ;

principalName
    : KW_USER principalIdentifier
    | KW_GROUP principalIdentifier
    | KW_ROLE id_
    ;

principalAlterName
    : KW_USER principalIdentifier
    | KW_ROLE id_
    | id_
    ;

withGrantOption
    : KW_WITH KW_GRANT KW_OPTION
    ;

grantOptionFor
    : KW_GRANT KW_OPTION KW_FOR
    ;

adminOptionFor
    : KW_ADMIN KW_OPTION KW_FOR
    ;

withAdminOption
    : KW_WITH KW_ADMIN KW_OPTION
    ;

metastoreCheck
    : KW_MSCK repair=KW_REPAIR? (
        KW_TABLE tableName (
            opt=(KW_ADD | KW_DROP | KW_SYNC) parts=KW_PARTITIONS partitionSelectorSpec?
        )?
    )
    ;

resourceList
    : resource (COMMA resource)*
    ;

resource
    : resType=resourceType resPath=StringLiteral
    ;

resourceType
    : KW_JAR
    | KW_FILE
    | KW_ARCHIVE
    ;

createFunctionStatement
    : KW_CREATE temp=KW_TEMPORARY? KW_FUNCTION functionNameCreate KW_AS StringLiteral (
        KW_USING rList=resourceList
    )?
    ;

dropFunctionStatement
    : KW_DROP temp=KW_TEMPORARY? KW_FUNCTION ifExists? functionNameForDDL
    ;

reloadFunctionsStatement
    : KW_RELOAD (KW_FUNCTIONS | KW_FUNCTION)
    ;

createMacroStatement
    : KW_CREATE KW_TEMPORARY KW_MACRO Identifier LPAREN columnNameTypeList? RPAREN expression
    ;

dropMacroStatement
    : KW_DROP KW_TEMPORARY KW_MACRO ifExists? Identifier
    ;

createIndexStatement
    : KW_CREATE KW_INDEX id_ KW_ON KW_TABLE tableName columnParenthesesList KW_AS indextype=StringLiteral (
        KW_WITH KW_DEFERRED KW_REBUILD
    )? (KW_IDXPROPERTIES tableProperties)? (KW_IN KW_TABLE tableName)? (
        KW_PARTITIONED KW_BY columnParenthesesList
    )? (tableRowFormat? tableFileFormat)? (KW_LOCATION locn=StringLiteral)? tablePropertiesPrefixed? tableComment?
    ;

dropIndexStatement
    : KW_DROP KW_INDEX ifExists? id_ KW_ON tableName
    ;

createViewStatement
    : KW_CREATE orReplace? KW_VIEW ifNotExists? name=viewNameCreate (
        LPAREN columnNameCommentList RPAREN
    )? tableComment? viewPartition? tablePropertiesPrefixed? KW_AS selectStatementWithCTE
    ;

viewPartition
    : KW_PARTITIONED KW_ON (LPAREN columnNameList | KW_SPEC LPAREN spec=partitionTransformSpec) RPAREN
    ;

viewOrganization
    : viewClusterSpec
    | viewComplexSpec
    ;

viewClusterSpec
    : KW_CLUSTERED KW_ON LPAREN columnNameList RPAREN
    ;

viewComplexSpec
    : viewDistSpec viewSortSpec
    ;

viewDistSpec
    : KW_DISTRIBUTED KW_ON LPAREN colList=columnNameList RPAREN
    ;

viewSortSpec
    : KW_SORTED KW_ON LPAREN colList=columnNameList RPAREN
    ;

dropViewStatement
    : KW_DROP KW_VIEW ifExists? viewName
    ;

createMaterializedViewStatement
    : KW_CREATE KW_MATERIALIZED KW_VIEW ifNotExists? name=viewNameCreate rewriteDisabled? tableComment? viewPartition? viewOrganization?
        tableRowFormat? tableFileFormat? tableLocation? tablePropertiesPrefixed? KW_AS selectStatementWithCTE
    ;

dropMaterializedViewStatement
    : KW_DROP KW_MATERIALIZED KW_VIEW ifExists? viewName
    ;

createScheduledQueryStatement
    : KW_CREATE KW_SCHEDULED KW_QUERY name=id_ scheduleSpec executedAsSpec? enableSpecification? definedAsSpec
    ;

dropScheduledQueryStatement
    : KW_DROP KW_SCHEDULED KW_QUERY name=id_
    ;

alterScheduledQueryStatement
    : KW_ALTER KW_SCHEDULED KW_QUERY name=id_ mod=alterScheduledQueryChange
    ;

alterScheduledQueryChange
    : scheduleSpec
    | executedAsSpec
    | enableSpecification
    | definedAsSpec
    | KW_EXECUTE
    ;

scheduleSpec
    : KW_CRON cronString=StringLiteral
    | KW_EVERY value=Number? qualifier=intervalQualifiers (
        (KW_AT | KW_OFFSET KW_BY) offsetTs=StringLiteral
    )?
    ;

executedAsSpec
    : KW_EXECUTED KW_AS executedAs=StringLiteral
    ;

definedAsSpec
    : KW_DEFINED? KW_AS statement
    ;

showStmtIdentifier
    : id_
    | StringLiteral
    ;

tableComment
    : KW_COMMENT comment=StringLiteral
    ;

// dtstack SparkSQL/HiveSQL lifecycle
tableLifecycle
    : KW_LIFECYCLE Number
    ;

createTablePartitionSpec
    : KW_PARTITIONED KW_BY (
        LPAREN (opt1=createTablePartitionColumnTypeSpec | opt2=createTablePartitionColumnSpec)
        | KW_SPEC LPAREN spec=partitionTransformSpec
    ) RPAREN
    ;

createTablePartitionColumnTypeSpec
    : columnNameTypeConstraint (COMMA columnNameTypeConstraint)*
    ;

createTablePartitionColumnSpec
    : columnName (COMMA columnName)*
    ;

partitionTransformSpec
    : columnNameTransformConstraint (COMMA columnNameTransformConstraint)*
    ;

columnNameTransformConstraint
    : partitionTransformType
    ;

partitionTransformType
    : columnName
    | (year | month | day | hour) LPAREN columnName RPAREN
    | (KW_TRUNCATE | KW_BUCKET) LPAREN value=Number COMMA columnName RPAREN
    ;

tableBuckets
    : KW_CLUSTERED KW_BY LPAREN bucketCols=columnNameList RPAREN (
        KW_SORTED KW_BY LPAREN sortCols=columnNameOrderList RPAREN
    )? KW_INTO num=Number KW_BUCKETS
    ;

tableImplBuckets
    : KW_CLUSTERED KW_INTO num=Number KW_BUCKETS
    ;

tableSkewed
    : KW_SKEWED KW_BY LPAREN skewedCols=columnNameList RPAREN KW_ON LPAREN skewedValues=skewedValueElement RPAREN storedAsDirs?
    ;

rowFormat
    : rowFormatSerde
    | rowFormatDelimited
    ;

recordReader
    : KW_RECORDREADER StringLiteral
    ;

recordWriter
    : KW_RECORDWRITER StringLiteral
    ;

rowFormatSerde
    : KW_ROW KW_FORMAT KW_SERDE name=StringLiteral (
        KW_WITH KW_SERDEPROPERTIES serdeprops=tableProperties
    )?
    ;

rowFormatDelimited
    : KW_ROW KW_FORMAT KW_DELIMITED tableRowFormatFieldIdentifier? tableRowFormatCollItemsIdentifier? tableRowFormatMapKeysIdentifier?
        tableRowFormatLinesIdentifier? tableRowNullFormat?
    ;

tableRowFormat
    : rowFormatDelimited
    | rowFormatSerde
    ;

tablePropertiesPrefixed
    : KW_TBLPROPERTIES tableProperties
    ;

tableProperties
    : LPAREN tablePropertiesList RPAREN
    ;

tablePropertiesList
    : keyValueProperty (COMMA keyValueProperty)*
    | keyProperty (COMMA keyProperty)*
    ;

keyValueProperty
    : key=StringLiteral EQUAL value=StringLiteral
    ;

keyProperty
    : key=StringLiteral
    ;

tableRowFormatFieldIdentifier
    : KW_FIELDS KW_TERMINATED KW_BY fldIdnt=StringLiteral (
        KW_ESCAPED KW_BY fldEscape=StringLiteral
    )?
    ;

tableRowFormatCollItemsIdentifier
    : KW_COLLECTION KW_ITEMS KW_TERMINATED KW_BY collIdnt=StringLiteral
    ;

tableRowFormatMapKeysIdentifier
    : KW_MAP KW_KEYS KW_TERMINATED KW_BY mapKeysIdnt=StringLiteral
    ;

tableRowFormatLinesIdentifier
    : KW_LINES KW_TERMINATED KW_BY linesIdnt=StringLiteral
    ;

tableRowNullFormat
    : KW_NULL KW_DEFINED KW_AS nullIdnt=StringLiteral
    ;

tableFileFormat
    : KW_STORED KW_AS KW_INPUTFORMAT inFmt=StringLiteral KW_OUTPUTFORMAT outFmt=StringLiteral (
        KW_INPUTDRIVER inDriver=StringLiteral KW_OUTPUTDRIVER outDriver=StringLiteral
    )?
    | KW_STORED KW_BY storageHandler=StringLiteral (
        KW_WITH KW_SERDEPROPERTIES serdeprops=tableProperties
    )? (KW_STORED KW_AS fileformat=id_)?
    | KW_STORED KW_BY genericSpec=id_ (KW_WITH KW_SERDEPROPERTIES serdeprops=tableProperties)? (
        KW_STORED KW_AS fileformat=id_
    )?
    | KW_STORED KW_AS genericSpec=id_
    ;

tableLocation
    : KW_LOCATION locn=StringLiteral
    ;

columnNameTypeList
    : columnNameType (COMMA columnNameType)*
    ;

columnNameTypeOrConstraintList
    : columnNameTypeOrConstraint (COMMA columnNameTypeOrConstraint)*
    ;

columnNameColonTypeList
    : columnNameColonType (COMMA columnNameColonType)*
    ;

columnNameList
    : columnName (COMMA columnName)*
    ;

columnName
    : id_ (DOT id_)*
    | {this.shouldMatchEmpty()}?
    ;

columnNameCreate
    : id_
    ;

extColumnName
    : columnName (DOT (KW_ELEM_TYPE | KW_KEY_TYPE | KW_VALUE_TYPE | id_))*
    ;

columnNameOrderList
    : columnNameOrder (COMMA columnNameOrder)*
    ;

columnParenthesesList
    : LPAREN columnNameList RPAREN
    ;

enableValidateSpecification
    : enableSpecification validateSpecification?
    | enforcedSpecification
    ;

enableSpecification
    : enable
    | disable
    ;

validateSpecification
    : KW_VALIDATE
    | KW_NOVALIDATE
    ;

enforcedSpecification
    : KW_ENFORCED
    | KW_NOT KW_ENFORCED
    ;

relySpecification
    : KW_RELY
    | KW_NORELY
    ;

createConstraint
    : (KW_CONSTRAINT constraintName=id_)? tableLevelConstraint constraintOptsCreate?
    ;

alterConstraintWithName
    : KW_CONSTRAINT constraintName=id_ tableLevelConstraint constraintOptsAlter?
    ;

tableLevelConstraint
    : pkUkConstraint
    | checkConstraint
    ;

pkUkConstraint
    : tableConstraintType pkCols=columnParenthesesList
    ;

checkConstraint
    : KW_CHECK LPAREN expression RPAREN
    ;

createForeignKey
    : (KW_CONSTRAINT constraintName=id_)? KW_FOREIGN KW_KEY fkCols=columnParenthesesList KW_REFERENCES tabName=tableName parCols=columnParenthesesList
        constraintOptsCreate?
    ;

alterForeignKeyWithName
    : KW_CONSTRAINT constraintName=id_ KW_FOREIGN KW_KEY fkCols=columnParenthesesList KW_REFERENCES tabName=tableName parCols=columnParenthesesList
        constraintOptsAlter?
    ;

skewedValueElement
    : skewedColumnValues
    | skewedColumnValuePairList
    ;

skewedColumnValuePairList
    : skewedColumnValuePair (COMMA skewedColumnValuePair)*
    ;

skewedColumnValuePair
    : LPAREN colValues=skewedColumnValues RPAREN
    ;

skewedColumnValues
    : skewedColumnValue (COMMA skewedColumnValue)*
    ;

skewedColumnValue
    : constant
    ;

skewedValueLocationElement
    : skewedColumnValue
    | skewedColumnValuePair
    ;

orderSpecification
    : KW_ASC
    | KW_DESC
    ;

nullOrdering
    : KW_NULLS (KW_FIRST | KW_LAST)
    ;

columnNameOrder
    : columnName orderSpec=orderSpecification? nullSpec=nullOrdering?
    ;

columnNameCommentList
    : columnNameComment (COMMA columnNameComment)*
    ;

columnNameComment
    : colName=columnNameCreate (KW_COMMENT comment=StringLiteral)?
    ;

orderSpecificationRewrite
    : KW_ASC
    | KW_DESC
    ;

columnRefOrder
    : (columnName | expression) orderSpec=orderSpecificationRewrite? nullSpec=nullOrdering?
    ;

columnNameType
    : colName=columnNameCreate colType (KW_COMMENT comment=StringLiteral)?
    ;

columnNameTypeOrConstraint
    : tableConstraint
    | columnNameTypeConstraint
    ;

tableConstraint
    : createForeignKey
    | createConstraint
    ;

columnNameTypeConstraint
    : colName=columnNameCreate colType columnConstraint? (KW_COMMENT comment=StringLiteral)?
    ;

columnConstraint
    : foreignKeyConstraint
    | colConstraint
    ;

foreignKeyConstraint
    : (KW_CONSTRAINT constraintName=id_)? KW_REFERENCES tabName=tableName LPAREN colName=columnName RPAREN constraintOptsCreate?
    ;

colConstraint
    : (KW_CONSTRAINT constraintName=id_)? columnConstraintType constraintOptsCreate?
    ;

alterColumnConstraint
    : alterForeignKeyConstraint
    | alterColConstraint
    ;

alterForeignKeyConstraint
    : (KW_CONSTRAINT constraintName=id_)? KW_REFERENCES tabName=tableName LPAREN colName=columnName RPAREN constraintOptsAlter?
    ;

alterColConstraint
    : (KW_CONSTRAINT constraintName=id_)? columnConstraintType constraintOptsAlter?
    ;

columnConstraintType
    : KW_NOT KW_NULL
    | KW_DEFAULT defaultVal
    | checkConstraint
    | tableConstraintType
    ;

defaultVal
    : constant
    | function_
    | castExpression
    ;

tableConstraintType
    : KW_PRIMARY KW_KEY
    | KW_UNIQUE
    ;

constraintOptsCreate
    : enableValidateSpecification relySpecification?
    ;

constraintOptsAlter
    : enableValidateSpecification relySpecification?
    ;

columnNameColonType
    : colName=columnNameCreate COLON colType (KW_COMMENT comment=StringLiteral)?
    ;

colType
    : type
    ;

colTypeList
    : colType (COMMA colType)*
    ;

type
    : primitiveType
    | listType
    | structType
    | mapType
    | unionType
    ;

primitiveType
    : KW_TINYINT
    | KW_SMALLINT
    | KW_INT
    | KW_INTEGER
    | KW_BIGINT
    | KW_BOOLEAN
    | KW_FLOAT
    | KW_REAL
    | KW_DOUBLE KW_PRECISION?
    | KW_DATE
    | KW_DATETIME
    | KW_TIMESTAMP
    | KW_TIMESTAMPLOCALTZ
    //| KW_TIMESTAMPTZ
    | KW_TIMESTAMP KW_WITH KW_LOCAL KW_TIME KW_ZONE
    //| KW_TIMESTAMP KW_WITH KW_TIME KW_ZONE
    // Uncomment to allow intervals as table column types
    //| KW_INTERVAL KW_YEAR KW_TO KW_MONTH
    //| KW_INTERVAL KW_DAY KW_TO KW_SECOND
    | KW_STRING
    | KW_BINARY
    | decimal (LPAREN prec=Number (COMMA scale=Number)? RPAREN)?
    | (KW_VARCHAR | KW_CHAR) LPAREN length=Number RPAREN
    ;

listType
    : KW_ARRAY LESSTHAN type GREATERTHAN
    ;

structType
    : KW_STRUCT LESSTHAN columnNameColonTypeList GREATERTHAN
    ;

mapType
    : KW_MAP LESSTHAN left=primitiveType COMMA right=type GREATERTHAN
    ;

unionType
    : KW_UNIONTYPE LESSTHAN colTypeList GREATERTHAN
    ;

setOperator
    : (KW_UNION | KW_INTERSECT | KW_EXCEPT | KW_MINUS) (KW_ALL | KW_DISTINCT)?
    ;

queryStatementExpression
    /* Would be nice to do this as a gated semantic perdicate
       But the predicate gets pushed as a lookahead decision.
       Calling rule doesnot know about topLevel
    */
    : w=withClause? queryStatementExpressionBody
    ;

queryStatementExpressionBody
    : fromStatement
    | regularBody
    ;

withClause
    : KW_WITH cteStatement (COMMA cteStatement)*
    ;

cteStatement
    : id_ (LPAREN colAliases=columnNameList RPAREN)? KW_AS LPAREN queryStatementExpression RPAREN
    ;

fromStatement
    : singleFromStatement (u=setOperator r=singleFromStatement)*
    ;

singleFromStatement
    : fromClause insertClause selectClause lateralView? whereClause? groupByClause? havingClause? window_clause? qualifyClause? orderByClause?
        clusterByClause? distributeByClause? sortByClause? limitClause? # fromInsertStmt
    | fromClause selectClause lateralView? whereClause? groupByClause? havingClause? window_clause? qualifyClause? orderByClause? clusterByClause?
        distributeByClause? sortByClause? limitClause? # fromSelectStmt
    ;

/*
The valuesClause rule below ensures that the parse tree for
"insert into table FOO values (1,2),(3,4)" looks the same as
"insert into table FOO select a,b from (values(1,2),(3,4)) as BAR(a,b)" which itself is made to look
very similar to the tree for "insert into table FOO select a,b from BAR".
*/
regularBody
    : i=insertClause s=selectStatement # insertStmt
    | selectStatement                  # selectStmt
    ;

atomSelectStatement
    : s=selectClause f=fromClause? w=whereClause? g=groupByClause? h=havingClause? win=window_clause? q=qualifyClause?
    | LPAREN selectStatement RPAREN
    | valuesSource
    ;

selectStatement
    : a=atomSelectStatement set=setOpSelectStatement? o=orderByClause? c=clusterByClause? d=distributeByClause? sort=sortByClause? l=limitClause?
    ;

setOpSelectStatement
    : (u=setOperator b=atomSelectStatement)+
    ;

selectStatementWithCTE
    : w=withClause? selectStatement
    ;

insertClause
    : KW_INSERT (
        KW_OVERWRITE destination ifNotExists?
        | KW_INTO KW_TABLE? tableOrPartition (LPAREN targetCols=columnNameList RPAREN)?
    )
    ;

destination
    : local=KW_LOCAL? KW_DIRECTORY StringLiteral tableRowFormat? tableFileFormat?
    | KW_TABLE tableOrPartition
    ;

limitClause
    : KW_LIMIT ((offset=Number COMMA)? num=Number | num=Number KW_OFFSET offset=Number)
    ;

/**
DELETE FROM <tableName> WHERE ...;
*/
deleteStatement
    : KW_DELETE KW_FROM tableName whereClause?
    ;

/*SET <columName> = (3 + col2)*/
columnAssignmentClause
    : columnName EQUAL precedencePlusExpressionOrDefault
    ;

precedencePlusExpressionOrDefault
    : defaultValue
    | precedencePlusExpression
    ;

/*SET col1 = 5, col2 = (4 + col4), ...*/
setColumnsClause
    : KW_SET columnAssignmentClause (COMMA columnAssignmentClause)*
    ;

/*
  UPDATE <table>
  SET col1 = val1, col2 = val2... WHERE ...
*/
updateStatement
    : KW_UPDATE tableName setColumnsClause whereClause?
    ;

/*
BEGIN user defined transaction boundaries; follows SQL 2003 standard exactly except for addition of
"setAutoCommitStatement" which is not in the standard doc but is supported by most SQL engines.
*/
sqlTransactionStatement
    : startTransactionStatement
    | commitStatement
    | rollbackStatement
    | setAutoCommitStatement
    ;

startTransactionStatement
    : KW_START KW_TRANSACTION (transactionMode (COMMA transactionMode)*)?
    ;

transactionMode
    : isolationLevel
    | transactionAccessMode
    ;

transactionAccessMode
    : KW_READ (KW_ONLY | KW_WRITE)
    ;

isolationLevel
    : KW_ISOLATION KW_LEVEL levelOfIsolation
    ;

/*READ UNCOMMITTED | READ COMMITTED | REPEATABLE READ | SERIALIZABLE may be supported later*/
levelOfIsolation
    : KW_SNAPSHOT
    ;

commitStatement
    : KW_COMMIT KW_WORK?
    ;

rollbackStatement
    : KW_ROLLBACK KW_WORK?
    ;

setAutoCommitStatement
    : KW_SET KW_AUTOCOMMIT booleanValueTok
    ;

/*
END user defined transaction boundaries
*/

abortTransactionStatement
    : KW_ABORT KW_TRANSACTIONS Number+
    ;

abortCompactionStatement
    : KW_ABORT KW_COMPACTIONS Number+
    ;

/*
BEGIN SQL Merge statement
*/
mergeStatement
    : KW_MERGE QUERY_HINT? KW_INTO tableName (KW_AS? id_)? KW_USING joinSourcePart KW_ON expression whenClauses
    ;

/*
Allow 0,1 or 2 WHEN MATCHED clauses and 0 or 1 WHEN NOT MATCHED
Each WHEN clause may have AND <boolean predicate>.
If 2 WHEN MATCHED clauses are present, 1 must be UPDATE the other DELETE and the 1st one
must have AND <boolean predicate>
*/
whenClauses
    : (whenMatchedAndClause | whenMatchedThenClause)* whenNotMatchedClause?
    ;

whenNotMatchedClause
    : KW_WHEN KW_NOT KW_MATCHED (KW_AND expression)? KW_THEN KW_INSERT targetCols=columnParenthesesList? KW_VALUES valueRowConstructor
    ;

whenMatchedAndClause
    : KW_WHEN KW_MATCHED KW_AND expression KW_THEN updateOrDelete
    ;

whenMatchedThenClause
    : KW_WHEN KW_MATCHED KW_THEN updateOrDelete
    ;

updateOrDelete
    : KW_UPDATE setColumnsClause
    | KW_DELETE
    ;

/*
END SQL Merge statement
*/

killQueryStatement
    : KW_KILL KW_QUERY StringLiteral+
    ;

/*
BEGIN SHOW COMPACTIONS statement
*/
compactionId
    : KW_COMPACT_ID EQUAL compactId=Number
    ;

compactionPool
    : KW_POOL poolName=StringLiteral
    ;

compactionType
    : KW_TYPE compactType=StringLiteral
    ;

compactionStatus
    : KW_STATUS status=StringLiteral
    ;

/*
END SHOW COMPACTIONS statement
*/

alterStatement
    : KW_ALTER (
        KW_TABLE tableName alterTableStatementSuffix
        | KW_VIEW viewName KW_AS? alterViewStatementSuffix
        | KW_MATERIALIZED KW_VIEW tableNameTree=viewName alterMaterializedViewStatementSuffix
        | db_schema alterDatabaseStatementSuffix
        | KW_DATACONNECTOR alterDataConnectorStatementSuffix
        | KW_INDEX alterIndexStatementSuffix
    )
    ;

alterTableStatementSuffix
    : alterStatementSuffixRename
    | alterStatementSuffixRecoverPartitions
    | alterStatementSuffixDropPartitions
    | alterStatementSuffixAddPartitions
    | alterStatementSuffixTouch
    | alterStatementSuffixArchive
    | alterStatementSuffixUnArchive
    | alterStatementSuffixProperties
    | alterStatementSuffixSkewedby
    | alterStatementSuffixExchangePartition
    | alterStatementPartitionKeyType
    | alterStatementSuffixDropConstraint
    | alterStatementSuffixAddConstraint
    | alterTblPartitionStatementSuffix
    | partitionSpec? alterTblPartitionStatementSuffix
    | alterStatementSuffixSetOwner
    | alterStatementSuffixSetPartSpec
    | alterStatementSuffixExecute
    ;

alterTblPartitionStatementSuffix
    : alterStatementSuffixFileFormat
    | alterStatementSuffixLocation
    | alterStatementSuffixMergeFiles
    | alterStatementSuffixSerdeProperties
    | alterStatementSuffixRenamePart
    | alterStatementSuffixBucketNum
    | alterTblPartitionStatementSuffixSkewedLocation
    | alterStatementSuffixClusterbySortby
    | alterStatementSuffixCompact
    | alterStatementSuffixUpdateStatsCol
    | alterStatementSuffixUpdateStats
    | alterStatementSuffixRenameCol
    | alterStatementSuffixAddCol
    | alterStatementSuffixUpdateColumns
    | alterStatementSuffixProtections
    ;

alterStatementPartitionKeyType
    : KW_PARTITION KW_COLUMN LPAREN columnNameType RPAREN
    ;

alterViewStatementSuffix
    : alterViewSuffixProperties
    | alterStatementSuffixRename
    | alterStatementSuffixAddPartitions
    | alterStatementSuffixDropPartitions
    | selectStatementWithCTE
    ;

alterMaterializedViewStatementSuffix
    : alterMaterializedViewSuffixRewrite
    | alterMaterializedViewSuffixRebuild
    ;

alterMaterializedViewSuffixRewrite
    : mvRewriteFlag=rewriteEnabled
    | mvRewriteFlag2=rewriteDisabled
    ;

alterMaterializedViewSuffixRebuild
    : KW_REBUILD
    ;

alterDatabaseStatementSuffix
    : alterDatabaseSuffixProperties
    | alterDatabaseSuffixSetOwner
    | alterDatabaseSuffixSetLocation
    ;

alterDatabaseSuffixProperties
    : name=dbSchemaName KW_SET KW_DBPROPERTIES dbProperties
    ;

alterDatabaseSuffixSetOwner
    : dbName=dbSchemaName KW_SET KW_OWNER principalAlterName
    ;

alterDatabaseSuffixSetLocation
    : dbName=dbSchemaName KW_SET (KW_LOCATION | KW_MANAGEDLOCATION) newLocation=StringLiteral
    ;

alterDatabaseSuffixSetManagedLocation
    : dbName=dbSchemaName KW_SET KW_MANAGEDLOCATION newLocation=StringLiteral
    ;

alterStatementSuffixRename
    : KW_RENAME KW_TO tableNameCreate
    ;

alterStatementSuffixAddCol
    : (add=KW_ADD | replace=KW_REPLACE) KW_COLUMNS LPAREN columnNameTypeList RPAREN restrictOrCascade?
    ;

alterStatementSuffixAddConstraint
    : KW_ADD (fk=alterForeignKeyWithName | alterConstraintWithName)
    ;

alterStatementSuffixUpdateColumns
    : KW_UPDATE KW_COLUMNS restrictOrCascade?
    ;

alterStatementSuffixProtections
    : enableSpecification KW_NO_DROP KW_CASCADE?
    | enableSpecification KW_OFFLINE
    ;

alterStatementSuffixDropConstraint
    : KW_DROP KW_CONSTRAINT cName=id_
    ;

alterStatementSuffixRenameCol
    : KW_CHANGE KW_COLUMN? oldName=columnName newName=columnNameCreate colType alterColumnConstraint? (
        KW_COMMENT comment=StringLiteral
    )? alterStatementChangeColPosition? restrictOrCascade?
    ;

alterStatementSuffixUpdateStatsCol
    : KW_UPDATE KW_STATISTICS KW_FOR KW_COLUMN? colName=columnName KW_SET tableProperties (
        KW_COMMENT comment=StringLiteral
    )?
    ;

alterStatementSuffixUpdateStats
    : KW_UPDATE KW_STATISTICS KW_SET tableProperties
    ;

alterStatementChangeColPosition
    : first=KW_FIRST
    | KW_AFTER afterCol=id_
    ;

alterStatementSuffixAddPartitions
    : KW_ADD ifNotExists? alterStatementSuffixAddPartitionsElement+
    ;

alterStatementSuffixAddPartitionsElement
    : partitionSpec partitionLocation?
    ;

alterStatementSuffixTouch
    : KW_TOUCH partitionSpec*
    ;

alterStatementSuffixArchive
    : KW_ARCHIVE partitionSpec*
    ;

alterStatementSuffixUnArchive
    : KW_UNARCHIVE partitionSpec*
    ;

partitionLocation
    : KW_LOCATION locn=StringLiteral
    ;

alterStatementSuffixRecoverPartitions
    : KW_RECOVER KW_PARTITIONS
    ;

alterStatementSuffixDropPartitions
    : KW_DROP ifExists? KW_PARTITION partitionSelectorSpec (
        COMMA KW_PARTITION partitionSelectorSpec
    )* dropPartitionsIgnoreClause? KW_PURGE? replicationClause?
    ;

alterStatementSuffixProperties
    : KW_SET KW_TBLPROPERTIES tableProperties
    | KW_UNSET KW_TBLPROPERTIES ifExists? tableProperties
    ;

alterViewSuffixProperties
    : KW_SET KW_TBLPROPERTIES tableProperties
    | KW_UNSET KW_TBLPROPERTIES ifExists? tableProperties
    ;

alterStatementSuffixSerdeProperties
    : KW_SET (
        KW_SERDE serdeName=StringLiteral (KW_WITH KW_SERDEPROPERTIES tableProperties)?
        | KW_SERDEPROPERTIES tableProperties
    )
    | KW_UNSET KW_SERDEPROPERTIES tableProperties
    ;

tablePartitionPrefix
    : tableName partitionSpec?
    ;

alterStatementSuffixFileFormat
    : KW_SET KW_FILEFORMAT fileFormat
    ;

alterStatementSuffixClusterbySortby
    : KW_NOT (KW_CLUSTERED | KW_SORTED)
    | tableBuckets
    ;

alterTblPartitionStatementSuffixSkewedLocation
    : KW_SET KW_SKEWED KW_LOCATION skewedLocations
    ;

skewedLocations
    : LPAREN skewedLocationsList RPAREN
    ;

skewedLocationsList
    : skewedLocationMap (COMMA skewedLocationMap)*
    ;

skewedLocationMap
    : key=skewedValueLocationElement EQUAL value=StringLiteral
    ;

alterStatementSuffixLocation
    : KW_SET KW_LOCATION newLoc=StringLiteral
    ;

alterStatementSuffixSkewedby
    : tableSkewed
    | KW_NOT (KW_SKEWED | storedAsDirs)
    ;

alterStatementSuffixExchangePartition
    : KW_EXCHANGE partitionSpec KW_WITH KW_TABLE exchangename=tableName
    ;

alterStatementSuffixRenamePart
    : KW_RENAME KW_TO partitionSpec
    ;

alterStatementSuffixStatsPart
    : KW_UPDATE KW_STATISTICS KW_FOR KW_COLUMN? colName=columnName KW_SET tableProperties (
        KW_COMMENT comment=StringLiteral
    )?
    ;

alterStatementSuffixMergeFiles
    : KW_CONCATENATE
    ;

alterStatementSuffixBucketNum
    : KW_INTO num=Number KW_BUCKETS
    ;

blocking
    : KW_AND KW_WAIT
    ;

compactPool
    : KW_POOL poolName=StringLiteral
    ;

alterStatementSuffixCompact
    : KW_COMPACT compactType=StringLiteral blocking? tableImplBuckets? orderByClause? compactPool? (
        KW_WITH KW_OVERWRITE KW_TBLPROPERTIES tableProperties
    )?
    ;

alterStatementSuffixSetOwner
    : KW_SET KW_OWNER principalName
    ;

alterStatementSuffixSetPartSpec
    : KW_SET KW_PARTITION KW_SPEC LPAREN spec=partitionTransformSpec RPAREN
    ;

alterStatementSuffixExecute
    : KW_EXECUTE (
        KW_ROLLBACK LPAREN rollbackParam=(StringLiteral | Number)
        | KW_EXPIRE_SNAPSHOTS LPAREN expireParam=StringLiteral
        | KW_SET_CURRENT_SNAPSHOT LPAREN snapshotParam=Number
    ) RPAREN
    ;

alterIndexStatementSuffix
    : id_ KW_ON tableName partitionSpec? KW_REBUILD
    ;

fileFormat
    : KW_INPUTFORMAT inFmt=StringLiteral KW_OUTPUTFORMAT outFmt=StringLiteral KW_SERDE serdeCls=StringLiteral (
        KW_INPUTDRIVER inDriver=StringLiteral KW_OUTPUTDRIVER outDriver=StringLiteral
    )?
    | genericSpec=id_
    ;

alterDataConnectorStatementSuffix
    : alterDataConnectorSuffixProperties
    | alterDataConnectorSuffixSetOwner
    | alterDataConnectorSuffixSetUrl
    ;

alterDataConnectorSuffixProperties
    : name=dbSchemaName KW_SET KW_DCPROPERTIES dcProperties
    ;

alterDataConnectorSuffixSetOwner
    : dcName=dbSchemaName KW_SET KW_OWNER principalAlterName
    ;

alterDataConnectorSuffixSetUrl
    : dcName=dbSchemaName KW_SET KW_URL newUri=StringLiteral
    ;

likeTableOrFile
    : KW_LIKE KW_FILE
    | KW_LIKE KW_FILE format=id_ uri=StringLiteral
    | KW_LIKE likeName=tableName
    ;

/**
Rules for parsing createtable
*/
createTableStatement
    : KW_CREATE temp=KW_TEMPORARY? trans=KW_TRANSACTIONAL? ext=KW_EXTERNAL? KW_TABLE ifNotExists? name=tableNameCreate (
        likeTableOrFile createTablePartitionSpec? tableRowFormat? tableFileFormat? tableLocation? tablePropertiesPrefixed? tableLifecycle?
        | (LPAREN columnNameTypeOrConstraintList RPAREN)? tableComment? createTablePartitionSpec? tableBuckets? tableSkewed? tableRowFormat?
            tableFileFormat? tableLocation? tablePropertiesPrefixed? tableLifecycle? (
            KW_AS selectStatementWithCTE
        )?
    )
    | KW_CREATE mgd=KW_MANAGED KW_TABLE ifNotExists? name=tableNameCreate (
        likeTableOrFile tableRowFormat? tableFileFormat? tableLocation? tablePropertiesPrefixed? tableLifecycle?
        | (LPAREN columnNameTypeOrConstraintList RPAREN)? tableComment? createTablePartitionSpec? tableBuckets? tableSkewed? tableRowFormat?
            tableFileFormat? tableLocation? tablePropertiesPrefixed? tableLifecycle? (
            KW_AS selectStatementWithCTE
        )?
    )
    ;

createDataConnectorStatement
    : KW_CREATE KW_DATACONNECTOR ifNotExists? name=id_ dataConnectorType? dataConnectorUrl? dataConnectorComment? (
        KW_WITH KW_DCPROPERTIES dcprops=dcProperties
    )?
    ;

dataConnectorComment
    : KW_COMMENT comment=StringLiteral
    ;

dataConnectorUrl
    : KW_URL url=StringLiteral
    ;

dataConnectorType
    : KW_TYPE dcType=StringLiteral
    ;

dcProperties
    : LPAREN dbPropertiesList RPAREN
    ;

dropDataConnectorStatement
    : KW_DROP KW_DATACONNECTOR ifExists? id_
    ;

tableAllColumns
    : (id_ DOT)* STAR
    ;

defaultValue
    : KW_DEFAULT
    ;

expressionList
    : expression (COMMA expression)*
    ;

aliasList
    : id_ (COMMA id_)*
    ;

/**
Rules for parsing fromClause
  from [col1, col2, col3] table1, [col4, col5] table2
*/
fromClause
    : KW_FROM fromSource
    ;

fromSource
    : uniqueJoinToken uniqueJoinSource (COMMA uniqueJoinSource)+
    | joinSource
    ;

atomjoinSource
    : tableSource lateralView*
    | virtualTableSource lateralView*
    | subQuerySource lateralView*
    | partitionedTableFunction lateralView*
    | LPAREN joinSource RPAREN
    ;

joinSource
    : atomjoinSource (
        joinToken joinSourcePart (KW_ON expression | KW_USING columnParenthesesList)?
    )*
    ;

joinSourcePart
    : (tableSource | virtualTableSource | subQuerySource | partitionedTableFunction) lateralView*
    ;

uniqueJoinSource
    : KW_PRESERVE? uniqueJoinTableSource uniqueJoinExpr
    ;

uniqueJoinExpr
    : LPAREN expressionList RPAREN
    ;

uniqueJoinToken
    : KW_UNIQUEJOIN
    ;

joinToken
    : COMMA
    | (
        KW_INNER
        | KW_CROSS
        | (KW_RIGHT | KW_FULL) KW_OUTER?
        | KW_LEFT (KW_SEMI | KW_ANTI | KW_OUTER)?
    )? KW_JOIN
    ;

lateralView
    : KW_LATERAL KW_VIEW KW_OUTER function_ tableAlias (KW_AS id_ (COMMA id_)*)?
    | COMMA? KW_LATERAL (
        KW_VIEW function_ tableAlias (KW_AS id_ (COMMA id_)*)?
        | KW_TABLE LPAREN valuesClause RPAREN KW_AS? tableAlias (LPAREN id_ (COMMA id_)* RPAREN)?
    )
    ;

tableAlias
    : id_
    ;

tableBucketSample
    : KW_TABLESAMPLE LPAREN KW_BUCKET numerator=Number KW_OUT KW_OF denominator=Number (
        KW_ON expr+=expression (COMMA expr+=expression)*
    )? RPAREN
    ;

splitSample
    : KW_TABLESAMPLE LPAREN (Number (KW_PERCENT | KW_ROWS) | ByteLengthLiteral) RPAREN
    ;

tableSample
    : tableBucketSample
    | splitSample
    ;

tableSource
    : tabname=tableOrView props=tableProperties? ts=tableSample? asOf=asOfClause? (
        KW_AS? alias=id_
    )?
    ;

asOfClause
    : KW_FOR (
        KW_SYSTEM_TIME KW_AS KW_OF asOfTime=expression
        | KW_FOR KW_SYSTEM_VERSION KW_AS KW_OF asOfVersion=Number
    )
    ;

uniqueJoinTableSource
    : tabname=tableOrView ts=tableSample? (KW_AS? alias=id_)?
    ;

dbSchemaName
    : id_
    ;

dbSchemaNameCreate
    : id_
    ;

tableOrView
    : tableName
    | viewName
    ;

tableName
    : db=id_ DOT tab=id_ (DOT meta=id_)?
    | tab=id_
    ;

tableNameCreate
    : db=id_ DOT tab=id_ (DOT meta=id_)?
    | tab=id_
    ;

viewName
    : (db=id_ DOT)? view=id_
    ;

viewNameCreate
    : (db=id_ DOT)? view=id_
    ;

subQuerySource
    : LPAREN queryStatementExpression RPAREN KW_AS? id_
    ;

/**
Rules for parsing PTF clauses
*/
partitioningSpec
    : partitionByClause orderByClause?
    | orderByClause
    | distributeByClause sortByClause?
    | sortByClause
    | clusterByClause
    ;

partitionTableFunctionSource
    : subQuerySource
    | tableSource
    | partitionedTableFunction
    ;

partitionedTableFunction
    : n=id_ LPAREN KW_ON ptfsrc=partitionTableFunctionSource spec=partitioningSpec? (
        Identifier LPAREN expression RPAREN (COMMA Identifier LPAREN expression RPAREN)*
    )? RPAREN alias=id_?
    ;

/**
Rules for parsing whereClause
 where a=b and ...
*/
whereClause
    : KW_WHERE searchCondition
    ;

searchCondition
    : expression
    ;

/**
Row Constructor
*/
valuesSource
    : valuesClause
    ;

/**
in support of SELECT * FROM (VALUES(1,2,3),(4,5,6),...) as FOO(a,b,c) and
 INSERT INTO <table> (col1,col2,...) VALUES(...),(...),...
 INSERT INTO <table> (col1,col2,...) SELECT * FROM (VALUES(1,2,3),(4,5,6),...) as Foo(a,b,c)

VALUES(1),(2) means 2 rows, 1 column each.
VALUES(1,2),(3,4) means 2 rows, 2 columns each.
VALUES(1,2,3) means 1 row, 3 columns
*/

valuesClause
    : KW_VALUES valuesTableConstructor
    ;

valuesTableConstructor
    : valueRowConstructor (COMMA valueRowConstructor)*
    | firstValueRowConstructor (COMMA valueRowConstructor)*
    ;

valueRowConstructor
    : expressionsInParenthesis
    ;

firstValueRowConstructor
    : LPAREN firstExpressionsWithAlias RPAREN
    ;

/*
This represents a clause like this:
TABLE(VALUES(1,2),(2,3)) as VirtTable(col1,col2)
*/
virtualTableSource
    : KW_TABLE LPAREN valuesClause RPAREN KW_AS? tableAlias (LPAREN id_ (COMMA id_)*)? RPAREN
    ;

/*
Rules for parsing selectClause
 select a,b,c ...
*/
selectClause
    : KW_SELECT QUERY_HINT? (all_distinct? selectList | KW_TRANSFORM selectTrfmClause)
    | trfmClause
    ;

all_distinct
    : KW_ALL
    | KW_DISTINCT
    ;

selectList
    : selectItem (COMMA selectItem)*
    ;

selectTrfmClause
    : LPAREN selectExpressionList RPAREN rowFormat recordWriter KW_USING StringLiteral (
        KW_AS (LPAREN (aliasList | columnNameTypeList) RPAREN | aliasList | columnNameTypeList)
    )? rowFormat recordReader
    ;

selectItem
    : tableAllColumns
    | ((columnName | expression) (KW_AS? id_ | KW_AS LPAREN id_ (COMMA id_)* RPAREN)?)
    ;

trfmClause
    : (KW_MAP | KW_REDUCE) selectExpressionList rowFormat recordWriter KW_USING StringLiteral (
        KW_AS (LPAREN (aliasList | columnNameTypeList) RPAREN | aliasList | columnNameTypeList)
    )? rowFormat recordReader
    ;

selectExpression
    : tableAllColumns
    | expression
    ;

selectExpressionList
    : selectExpression (COMMA selectExpression)*
    ;

/**
Rules for windowing clauses
*/
window_clause
    : KW_WINDOW window_defn (COMMA window_defn)*
    ;

window_defn
    : id_ KW_AS window_specification
    ;

window_specification
    : id_
    | LPAREN id_? partitioningSpec? window_frame? RPAREN
    ;

window_frame
    : window_range_expression
    | window_value_expression
    ;

window_range_expression
    : KW_ROWS (
        window_frame_start_boundary
        | KW_BETWEEN window_frame_boundary KW_AND window_frame_boundary
    )
    ;

window_value_expression
    : KW_RANGE (
        window_frame_start_boundary
        | KW_BETWEEN window_frame_boundary KW_AND window_frame_boundary
    )
    ;

window_frame_start_boundary
    : KW_UNBOUNDED KW_PRECEDING
    | KW_CURRENT KW_ROW
    | Number KW_PRECEDING
    ;

window_frame_boundary
    : (KW_UNBOUNDED | Number) (KW_PRECEDING | KW_FOLLOWING)
    | KW_CURRENT KW_ROW
    ;

// group by a,b
groupByClause
    : KW_GROUP KW_BY groupby_expression
    ;

// support for new and old rollup/cube syntax
groupby_expression
    : columnName
    | rollupStandard
    | rollupOldSyntax
    | groupByEmpty
    ;

groupByEmpty
    : LPAREN RPAREN
    ;

// standard rollup syntax
rollupStandard
    : (rollup=KW_ROLLUP | cube=KW_CUBE) LPAREN expression (COMMA expression)* RPAREN
    ;

// old hive rollup syntax
rollupOldSyntax
    : expr=expressionsNotInParenthesis (rollup=KW_WITH KW_ROLLUP | cube=KW_WITH KW_CUBE)? (
        sets=KW_GROUPING KW_SETS LPAREN groupingSetExpression (COMMA groupingSetExpression)* RPAREN
    )?
    ;

groupingSetExpression
    : groupingSetExpressionMultiple
    | groupingExpressionSingle
    ;

groupingSetExpressionMultiple
    : LPAREN expression? (COMMA expression)* RPAREN
    ;

groupingExpressionSingle
    : expression
    ;

havingClause
    : KW_HAVING havingCondition
    ;

qualifyClause
    : KW_QUALIFY expression
    ;

havingCondition
    : expression
    ;

expressionsInParenthesis
    : LPAREN expressionsNotInParenthesis RPAREN
    ;

expressionsNotInParenthesis
    : first=expressionOrDefault more=expressionPart?
    ;

expressionPart
    : (COMMA expressionOrDefault)+
    ;

expressionOrDefault
    : defaultValue
    | expression
    ;

/**
Parses comma separated list of expressions with optionally specified aliases.
 <expression> [<alias>] [, <expression> [<alias>]]
*/
firstExpressionsWithAlias
    : first=expression KW_AS? colAlias=id_? (COMMA expressionWithAlias)*
    ;

/** Parses expressions which may have alias.
 If alias is not specified generate one.
*/
expressionWithAlias
    : expression KW_AS? alias=id_?
    ;

expressions
    : expressionsInParenthesis
    | expressionsNotInParenthesis
    ;

columnRefOrderInParenthesis
    : LPAREN columnRefOrder (COMMA columnRefOrder)* RPAREN
    ;

columnRefOrderNotInParenthesis
    : columnRefOrder (COMMA columnRefOrder)*
    ;

// order by a,b
orderByClause
    : KW_ORDER KW_BY columnRefOrder (COMMA columnRefOrder)*
    ;

clusterByClause
    : KW_CLUSTER KW_BY expressions
    ;

partitionByClause
    : KW_PARTITION KW_BY expressions
    ;

distributeByClause
    : KW_DISTRIBUTE KW_BY expressions
    ;

sortByClause
    : KW_SORT KW_BY (columnRefOrderInParenthesis | columnRefOrderNotInParenthesis)
    ;

// TRIM([LEADING|TRAILING|BOTH] trim_characters FROM str)
trimFunction
    : KW_TRIM LPAREN (leading=KW_LEADING | trailing=KW_TRAILING | KW_BOTH)? trim_characters=selectExpression? KW_FROM str=selectExpression RPAREN
    ;

// fun(par1, par2, par3)
function_
    : trimFunction
    | functionNameForInvoke LPAREN (
        star=STAR
        | dist=all_distinct? (selectExpression (COMMA selectExpression)*)?
    ) (
        // SELECT rank(3) WITHIN GROUP (<order by clause>)
        RPAREN within=KW_WITHIN KW_GROUP LPAREN ordBy=orderByClause RPAREN
        // No null treatment: SELECT first_value(b) OVER (<window spec>)
        // Standard null treatment spec: SELECT first_value(b) IGNORE NULLS OVER (<window spec>)
        | RPAREN nt=null_treatment? KW_OVER ws=window_specification
        // Non-standard null treatment spec: SELECT first_value(b IGNORE NULLS) OVER (<window spec>)
        | nt=null_treatment RPAREN KW_OVER ws=window_specification
        | RPAREN
    )
    ;

null_treatment
    : KW_RESPECT KW_NULLS
    | KW_IGNORE KW_NULLS
    ;

functionNameCreate
    : functionIdentifier
    ;

functionNameForDDL // Function name use to DDL, such as drop function
    : userDefinedFuncName
    | StringLiteral
    ;

functionNameForInvoke // Function name used to invoke
    : userDefinedFuncName
    | internalFunctionName
    ;

userDefinedFuncName // User Defined Function
    : functionIdentifier
    ;

internalFunctionName // Hive Internal Function
    : sql11ReservedKeywordsUsedAsFunctionName
    | sysFuncNames
    ;

castExpression
    : KW_CAST LPAREN expression KW_AS toType=primitiveType (fmt=KW_FORMAT StringLiteral)? RPAREN
    ;

caseExpression
    : KW_CASE expression (KW_WHEN expression KW_THEN expression)+ (KW_ELSE expression)? KW_END
    ;

whenExpression
    : KW_CASE (KW_WHEN expression KW_THEN expression)+ (KW_ELSE expression)? KW_END
    ;

floorExpression
    : KW_FLOOR LPAREN expression (KW_TO floorUnit=floorDateQualifiers)? RPAREN
    ;

floorDateQualifiers
    : year
    | KW_QUARTER
    | month
    | week
    | day
    | hour
    | minute
    | second
    ;

extractExpression
    : KW_EXTRACT LPAREN timeUnit=timeQualifiers KW_FROM expression RPAREN
    ;

timeQualifiers
    : year
    | KW_QUARTER
    | month
    | week
    | day
    | hour
    | minute
    | second
    ;

constant
    : intervalLiteral
    | Number
    | dateLiteral
    | timestampLiteral
    | timestampLocalTZLiteral
    | StringLiteral
    | stringLiteralSequence
    | IntegralLiteral
    | NumberLiteral
    | charSetStringLiteral
    | booleanValue
    | KW_NULL
    | prepareStmtParam
    | Identifier
    ;

prepareStmtParam
    : p=parameterIdx
    ;

parameterIdx
    : QUESTION
    ;

stringLiteralSequence
    : StringLiteral StringLiteral+
    ;

charSetStringLiteral
    : csName=CharSetName csLiteral=CharSetLiteral
    ;

dateLiteral
    : KW_DATE StringLiteral
    | KW_CURRENT_DATE
    ;

timestampLiteral
    : KW_TIMESTAMP StringLiteral
    | KW_CURRENT_TIMESTAMP
    ;

timestampLocalTZLiteral
    : KW_TIMESTAMPLOCALTZ StringLiteral
    ;

intervalValue
    : StringLiteral
    | Number
    ;

intervalLiteral
    : value=intervalValue qualifiers=intervalQualifiers
    ;

intervalExpression
    : LPAREN value=intervalValue RPAREN qualifiers=intervalQualifiers
    | KW_INTERVAL (value=intervalValue | LPAREN expr=expression RPAREN) qualifiers=intervalQualifiers
    ;

intervalQualifiers
    : year KW_TO month
    | day KW_TO second
    | year
    | month
    | day
    | hour
    | minute
    | second
    ;

expression
    : precedenceOrExpression
    ;

atomExpression
    : constant
    | intervalExpression
    | castExpression
    | extractExpression
    | floorExpression
    | caseExpression
    | whenExpression
    | subQueryExpression
    | function_
    | expressionsInParenthesis
    | id_
    ;

precedenceFieldExpression
    : atomExpression (LSQUARE expression RSQUARE | DOT id_)*
    ;

precedenceUnaryOperator
    : PLUS
    | MINUS
    | TILDE
    | BITWISENOT
    ;

precedenceUnaryPrefixExpression
    : precedenceUnaryOperator* precedenceFieldExpression
    ;

precedenceBitwiseXorOperator
    : BITWISEXOR
    ;

precedenceBitwiseXorExpression
    : precedenceUnaryPrefixExpression (
        precedenceBitwiseXorOperator precedenceUnaryPrefixExpression
    )*
    ;

precedenceStarOperator
    : STAR
    | DIVIDE
    | MOD
    | DIV
    ;

precedenceStarExpression
    : precedenceBitwiseXorExpression (precedenceStarOperator precedenceBitwiseXorExpression)*
    ;

precedencePlusOperator
    : PLUS
    | MINUS
    ;

precedencePlusExpression
    : precedenceStarExpression (precedencePlusOperator precedenceStarExpression)*
    ;

precedenceConcatenateOperator
    : CONCATENATE
    ;

precedenceConcatenateExpression
    : precedencePlusExpression (precedenceConcatenateOperator plus=precedencePlusExpression)*
    ;

precedenceAmpersandOperator
    : AMPERSAND
    ;

precedenceAmpersandExpression
    : precedenceConcatenateExpression (precedenceAmpersandOperator precedenceConcatenateExpression)*
    ;

precedenceBitwiseOrOperator
    : BITWISEOR
    ;

precedenceBitwiseOrExpression
    : precedenceAmpersandExpression (precedenceBitwiseOrOperator precedenceAmpersandExpression)*
    ;

precedenceRegexpOperator
    : KW_LIKE
    | KW_RLIKE
    | KW_REGEXP
    ;

precedenceSimilarOperator
    : precedenceRegexpOperator
    | LESSTHANOREQUALTO
    | LESSTHAN
    | GREATERTHANOREQUALTO
    | GREATERTHAN
    ;

subQueryExpression
    : LPAREN selectStatement RPAREN
    ;

precedenceSimilarExpression
    : precedenceSimilarExpressionMain
    | KW_EXISTS subQueryExpression
    ;

precedenceSimilarExpressionMain
    : a=precedenceBitwiseOrExpression part=precedenceSimilarExpressionPart?
    ;

precedenceSimilarExpressionPart
    : precedenceSimilarOperator equalExpr=precedenceBitwiseOrExpression
    | precedenceSimilarExpressionAtom
    | KW_NOT precedenceSimilarExpressionPartNot
    ;

precedenceSimilarExpressionAtom
    : KW_IN precedenceSimilarExpressionIn
    | KW_BETWEEN min=precedenceBitwiseOrExpression KW_AND max=precedenceBitwiseOrExpression
    | KW_LIKE (KW_ANY | KW_ALL) expr=expressionsInParenthesis
    | precedenceSimilarExpressionQuantifierPredicate
    ;

precedenceSimilarExpressionQuantifierPredicate
    : subQuerySelectorOperator quantifierType subQueryExpression
    ;

quantifierType
    : KW_ANY
    | KW_SOME
    | KW_ALL
    ;

precedenceSimilarExpressionIn
    : subQueryExpression
    | expr=expressionsInParenthesis
    ;

precedenceSimilarExpressionPartNot
    : precedenceRegexpOperator notExpr=precedenceBitwiseOrExpression
    | precedenceSimilarExpressionAtom
    ;

precedenceDistinctOperator
    : KW_IS KW_DISTINCT KW_FROM
    ;

precedenceEqualOperator
    : EQUAL
    | EQUAL_NS
    | NOTEQUAL
    | KW_IS KW_NOT KW_DISTINCT KW_FROM
    ;

precedenceEqualExpression
    : precedenceSimilarExpression (
        equal+=precedenceEqualOperator p+=precedenceSimilarExpression
        | dist+=precedenceDistinctOperator p+=precedenceSimilarExpression
    )*
    ;

isCondition
    : KW_NULL
    | KW_TRUE
    | KW_FALSE
    | KW_UNKNOWN
    | KW_NOT KW_NULL
    | KW_NOT KW_TRUE
    | KW_NOT KW_FALSE
    | KW_NOT KW_UNKNOWN
    ;

precedenceUnarySuffixExpression
    : precedenceEqualExpression (a=KW_IS isCondition)?
    ;

precedenceNotOperator
    : KW_NOT
    ;

precedenceNotExpression
    : precedenceNotOperator* precedenceUnarySuffixExpression
    ;

precedenceAndOperator
    : KW_AND
    ;

precedenceAndExpression
    : precedenceNotExpression (precedenceAndOperator precedenceNotExpression)*
    ;

precedenceOrOperator
    : KW_OR
    ;

precedenceOrExpression
    : precedenceAndExpression (precedenceOrOperator precedenceAndExpression)*
    ;

booleanValue
    : KW_TRUE
    | KW_FALSE
    ;

booleanValueTok
    : KW_TRUE
    | KW_FALSE
    ;

tableOrPartition
    : tableName partitionSpec?
    ;

partitionSpec
    : KW_PARTITION LPAREN partitionVal (COMMA partitionVal)* RPAREN
    ;

partitionVal
    : id_ (EQUAL constant)?
    ;

partitionSelectorSpec
    : LPAREN partitionSelectorVal (COMMA partitionSelectorVal)* RPAREN
    ;

partitionSelectorVal
    : id_ partitionSelectorOperator constant
    ;

partitionSelectorOperator
    : KW_LIKE
    | subQuerySelectorOperator
    ;

subQuerySelectorOperator
    : EQUAL
    | NOTEQUAL
    | LESSTHANOREQUALTO
    | LESSTHAN
    | GREATERTHANOREQUALTO
    | GREATERTHAN
    ;

sysFuncNames
    : KW_AND
    | KW_OR
    | KW_NOT
    | KW_LIKE
    | KW_IF
    | KW_CASE
    | KW_WHEN
    | KW_FLOOR
    | KW_TINYINT
    | KW_SMALLINT
    | KW_INT
    | KW_INTEGER
    | KW_BIGINT
    | KW_FLOAT
    | KW_REAL
    | KW_DOUBLE
    | KW_BOOLEAN
    | KW_STRING
    | KW_BINARY
    | KW_ARRAY
    | KW_MAP
    | KW_STRUCT
    | KW_UNIONTYPE
    | EQUAL
    | EQUAL_NS
    | NOTEQUAL
    | LESSTHANOREQUALTO
    | LESSTHAN
    | GREATERTHANOREQUALTO
    | GREATERTHAN
    | DIVIDE
    | PLUS
    | MINUS
    | STAR
    | MOD
    | DIV
    | AMPERSAND
    | TILDE
    | BITWISEOR
    | BITWISEXOR
    | KW_RLIKE
    | KW_REGEXP
    | KW_IN
    | KW_BETWEEN
    ;

id_
    : Identifier
    | nonReserved
    ;

functionIdentifier
    : id_ (DOT fn=id_)?
    ;

principalIdentifier
    : id_
    //| QuotedIdentifier
    ;

/**
 Here is what you have to do if you would like to add a new keyword.
 Note that non reserved keywords are basically the keywords that can be used as identifiers.
 (1) Add a new entry to HiveLexer, e.g., KW_TRUE : 'TRUE';
 (2) If it is reserved, you do NOT need to change IdentifiersParser.g
                        because all the KW_* are automatically not only keywords, but also reserved keywords.
                        However, you need to add a test to TestSQL11ReservedKeyWordsNegative.java.
     Otherwise it is non-reserved, you need to put them in the nonReserved list below.
If you are not sure, please refer to the SQL2011 column in
http://www.postgresql.org/docs/9.5/static/sql-keywords-appendix.html
*/
nonReserved
    : KW_ABORT
    | KW_ACTIVATE
    | KW_ACTIVE
    | KW_ADD
    | KW_ADMIN
    | KW_AFTER
    | KW_ALLOC_FRACTION
    | KW_ANALYZE
    | KW_ARCHIVE
    | KW_ASC
    | KW_AST
    | KW_AT
    | KW_AUTOCOMMIT
    | KW_BATCH
    | KW_BEFORE
    | KW_BUCKET
    | KW_BUCKETS
    | KW_CACHE
    | KW_CASCADE
    | KW_CBO
    | KW_CHANGE
    | KW_CHECK
    | KW_CLUSTER
    | KW_CLUSTERED
    | KW_CLUSTERSTATUS
    | KW_COLLECTION
    | KW_COLUMNS
    | KW_COMMENT
    | KW_COMPACT
    | KW_COMPACTIONS
    | KW_COMPUTE
    | KW_CONCATENATE
    | KW_CONTINUE
    | KW_COST
    | KW_CRON
    | KW_DATA
    | KW_DATABASES
    | KW_DATETIME
    | KW_DAY
    | KW_DAYS
    | KW_DAYOFWEEK
    | KW_DBPROPERTIES
    | KW_DCPROPERTIES
    | KW_DEBUG
    | KW_DEFAULT
    | KW_DEFERRED
    | KW_DEFINED
    | KW_DELIMITED
    | KW_DEPENDENCY
    | KW_DESC
    | KW_DETAIL
    | KW_DIRECTORIES
    | KW_DIRECTORY
    | KW_DISABLE
    | KW_DISABLED
    | KW_DISTRIBUTE
    | KW_DISTRIBUTED
    | KW_DO
    | KW_DUMP
    | KW_ELEM_TYPE
    | KW_ENABLE
    | KW_ENABLED
    | KW_ENFORCED
    | KW_ESCAPED
    | KW_EVERY
    | KW_EXCLUSIVE
    | KW_EXECUTE
    | KW_EXECUTED
    | KW_EXPIRE_SNAPSHOTS
    | KW_EXPLAIN
    | KW_EXPORT
    | KW_EXPRESSION
    | KW_FIELDS
    | KW_FILE
    | KW_FILEFORMAT
    | KW_FIRST
    | KW_FORMAT
    | KW_FORMATTED
    | KW_FUNCTIONS
    | KW_HOLD_DDLTIME
    | KW_HOUR
    | KW_HOURS
    | KW_IDXPROPERTIES
    | KW_IGNORE
    | KW_INDEX
    | KW_INDEXES
    | KW_INPATH
    | KW_INPUTDRIVER
    | KW_INPUTFORMAT
    | KW_ISOLATION
    | KW_ITEMS
    | KW_JAR
    | KW_JOINCOST
    | KW_KEY
    | KW_KEYS
    | KW_KEY_TYPE
    | KW_KILL
    | KW_LAST
    | KW_LEVEL
    | KW_LIFECYCLE
    | KW_LIMIT
    | KW_LINES
    | KW_LOAD
    | KW_LOCATION
    | KW_LOCK
    | KW_LOCKS
    | KW_LOGICAL
    | KW_LONG
    | KW_MANAGED
    | KW_MANAGEDLOCATION
    | KW_MANAGEMENT
    | KW_MAPJOIN
    | KW_MAPPING
    | KW_MATCHED
    | KW_MATERIALIZED
    | KW_METADATA
    | KW_MINUTE
    | KW_MINUTES
    | KW_MONTH
    | KW_MONTHS
    | KW_MOVE
    | KW_MSCK
    | KW_NORELY
    | KW_NOSCAN
    | KW_NOVALIDATE
    | KW_NO_DROP
    | KW_NULLS
    | KW_OFFLINE
    | KW_OFFSET
    | KW_OPERATOR
    | KW_OPTION
    | KW_OUTPUTDRIVER
    | KW_OUTPUTFORMAT
    | KW_OVERWRITE
    | KW_OWNER
    | KW_PARTITIONED
    | KW_PARTITIONS
    | KW_PATH
    | KW_PLAN
    | KW_PLANS
    | KW_PLUS
    | KW_POOL
    | KW_PRINCIPALS
    | KW_PROTECTION
    | KW_PURGE
    | KW_QUARTER
    | KW_QUERY
    | KW_QUERY_PARALLELISM
    | KW_READ
    | KW_READONLY
    | KW_REBUILD
    | KW_RECORDREADER
    | KW_RECORDWRITER
    | KW_RELOAD
    | KW_RELY
    | KW_REMOTE
    | KW_RENAME
    | KW_REOPTIMIZATION
    | KW_REPAIR
    | KW_REPL
    | KW_REPLACE
    | KW_REPLICATION
    | KW_RESOURCE
    | KW_RESPECT
    | KW_RESTRICT
    | KW_REWRITE
    | KW_ROLE
    | KW_ROLES
    | KW_SCHEDULED
    | KW_SCHEDULING_POLICY
    | KW_SCHEMA
    | KW_SCHEMAS
    | KW_SECOND
    | KW_SECONDS
    | KW_SEMI
    | KW_SERDE
    | KW_SERDEPROPERTIES
    | KW_SERVER
    | KW_SETS
    | KW_SET_CURRENT_SNAPSHOT
    | KW_SHARED
    | KW_SHOW
    | KW_SHOW_DATABASE
    | KW_SKEWED
    | KW_SNAPSHOT
    | KW_SORT
    | KW_SORTED
    | KW_SPEC
    | KW_SSL
    | KW_STATISTICS
    | KW_STATUS
    | KW_STORED
    | KW_STREAMTABLE
    | KW_STRING
    | KW_STRUCT
    | KW_SUMMARY
    | KW_SYSTEM_TIME
    | KW_SYSTEM_VERSION
    | KW_TABLES
    | KW_TBLPROPERTIES
    | KW_TEMPORARY
    | KW_TERMINATED
    | KW_TIMESTAMPTZ
    | KW_TINYINT
    | KW_TOUCH
    | KW_TRANSACTION
    | KW_TRANSACTIONAL
    | KW_TRANSACTIONS
    | KW_TRIM
    | KW_TYPE
    | KW_UNARCHIVE
    | KW_UNDO
    | KW_UNIONTYPE
    | KW_UNKNOWN
    | KW_UNLOCK
    | KW_UNMANAGED
    | KW_UNSET
    | KW_UNSIGNED
    | KW_URI
    | KW_URL
    | KW_USE
    | KW_UTC
    | KW_UTCTIMESTAMP
    | KW_VALIDATE
    | KW_VALUE_TYPE
    | KW_VECTORIZATION
    | KW_VIEW
    | KW_VIEWS
    | KW_WAIT
    | KW_WEEK
    | KW_WEEKS
    | KW_WHILE
    | KW_WITHIN
    | KW_WORK
    | KW_WORKLOAD
    | KW_WRITE
    | KW_YEAR
    | KW_YEARS
    | KW_ZONE
    ;

/**
The following SQL2011 reserved keywords are used as function name only, but not as identifiers.
*/
sql11ReservedKeywordsUsedAsFunctionName
    : KW_ARRAY
    | KW_BIGINT
    | KW_BINARY
    | KW_BOOLEAN
    | KW_CURRENT_DATE
    | KW_CURRENT_TIMESTAMP
    | KW_DATE
    | KW_DOUBLE
    | KW_FLOAT
    | KW_GROUPING
    | KW_IF
    | KW_INT
    | KW_INTEGER
    | KW_MAP
    | KW_REAL
    | KW_SMALLINT
    | KW_TIMESTAMP
    ;

// starting rule
hint
    : hintList EOF
    ;

hintList
    : hintItem (COMMA hintItem)*
    ;

hintItem
    : hintName (LPAREN hintArgs RPAREN)?
    ;

hintName
    : KW_MAPJOIN
    | KW_SEMI
    | KW_STREAMTABLE
    | KW_PKFK_JOIN
    ;

hintArgs
    : hintArgName (COMMA hintArgName)*
    ;

hintArgName
    : Identifier
    | Number
    | KW_NONE
    ;

//----------------------- Rules for parsing Prepare statement-----------------------------
prepareStatement
    : KW_PREPARE id_ KW_FROM queryStatementExpression
    ;

executeStatement
    : KW_EXECUTE id_ KW_USING executeParamList
    ;

setConfigPropertiesStatement
    : KW_SET configPropertiesItem (DOT configPropertiesItem)* EQUAL .*?
    ;

configPropertiesItem
    : id_
    | KW_JOIN
    | KW_PARTITION
    | KW_MAP
    | KW_REDUCE
    | KW_USER
    | KW_PERCENT
    | KW_INTERVAL
    | KW_ROWS
    | KW_UNION
    | KW_GROUP
    | KW_MERGE
    | KW_NULL
    | KW_FETCH
    | KW_LOCAL
    | KW_DROP
    | KW_TABLE
    | KW_ON
    | KW_ROW
    | KW_GROUPING
    | KW_SET
    | KW_FORCE
    | KW_START
    | KW_INSERT
    | KW_CONF
    | KW_INTO
    | KW_UNIQUE
    | KW_COLUMN
    | KW_TRANSFORM
    | KW_DISTINCT
    | KW_IN
    | KW_REFERENCES
    | KW_TIMESTAMP
    | KW_ONLY
    | KW_END
    | KW_FUNCTION
    | KW_UPDATE
    | KW_AUTHORIZATION
    | KW_DDL
    | KW_VALUES
    | KW_TIME
    | KW_IS
    | KW_FOR
    | KW_NOT
    | KW_BINARY
    | KW_USING
    | KW_READS
    | KW_BETWEEN
    | KW_CURRENT
    | KW_AS
    ;

//TODO: instead of constant using expression will provide richer and broader parameters
executeParamList
    : constant (COMMA constant)*
    ;

resourcePlanDdlStatements
    : createResourcePlanStatement
    | alterResourcePlanStatement
    | dropResourcePlanStatement
    | globalWmStatement
    | replaceResourcePlanStatement
    | createTriggerStatement
    | alterTriggerStatement
    | dropTriggerStatement
    | createPoolStatement
    | alterPoolStatement
    | dropPoolStatement
    | createMappingStatement
    | alterMappingStatement
    | dropMappingStatement
    ;

rpAssign
    : KW_QUERY_PARALLELISM EQUAL parallelism=Number
    | KW_DEFAULT KW_POOL EQUAL poolPath
    ;

rpAssignList
    : rpAssign (COMMA rpAssign)*
    ;

rpUnassign
    : KW_QUERY_PARALLELISM
    | KW_DEFAULT KW_POOL
    ;

rpUnassignList
    : rpUnassign (COMMA rpUnassign)*
    ;

createResourcePlanStatement
    : KW_CREATE KW_RESOURCE KW_PLAN ifNotExists? (
        name=id_ KW_LIKE likeName=id_
        | name=id_ (KW_WITH rpAssignList)?
    )
    ;

withReplace
    : KW_WITH KW_REPLACE
    ;

activate
    : KW_ACTIVATE withReplace?
    ;

enable
    : KW_ENABLE
    | KW_ENABLED
    ;

disable
    : KW_DISABLE
    | KW_DISABLED
    ;

unmanaged
    : KW_UNMANAGED
    ;

year
    : KW_YEAR
    | KW_YEARS
    ;

month
    : KW_MONTH
    | KW_MONTHS
    ;

week
    : KW_WEEK
    | KW_WEEKS
    ;

day
    : KW_DAY
    | KW_DAYS
    ;

hour
    : KW_HOUR
    | KW_HOURS
    ;

minute
    : KW_MINUTE
    | KW_MINUTES
    ;

second
    : KW_SECOND
    | KW_SECONDS
    ;

decimal
    : KW_DEC
    | KW_DECIMAL
    | KW_NUMERIC
    ;

alterResourcePlanStatement
    : KW_ALTER KW_RESOURCE KW_PLAN name=id_ (
        KW_VALIDATE
        | disable
        | KW_SET rpAssignList
        | KW_UNSET rpUnassignList
        | KW_RENAME KW_TO newName=id_
        | activate enable?
        | enable activate?
    )
    ;

/** It might make sense to make this more generic, if something else could be enabled/disabled.
    For now, it's only used for WM. Translate into another form of an alter statement. */
globalWmStatement
    : (enable | disable) KW_WORKLOAD KW_MANAGEMENT
    ;

replaceResourcePlanStatement
    : KW_REPLACE (
        KW_ACTIVE KW_RESOURCE KW_PLAN KW_WITH src=id_
        | KW_RESOURCE KW_PLAN dest=id_ KW_WITH src=id_
    )
    ;

dropResourcePlanStatement
    : KW_DROP KW_RESOURCE KW_PLAN ifExists? name=id_
    ;

poolPath
    : id_ (DOT id_)*
    ;

triggerExpression
    : triggerAtomExpression
    ;

triggerExpressionStandalone
    : triggerExpression EOF
    ;

/*
  The rules triggerOrExpression and triggerAndExpression are not being used right now.
  Only > operator is supported, this should be changed if logic in ExpressionFactory changes.
*/
triggerOrExpression
    : triggerAndExpression (KW_OR triggerAndExpression)*
    ;

triggerAndExpression
    : triggerAtomExpression (KW_AND triggerAtomExpression)*
    ;

triggerAtomExpression
    : id_ comparisionOperator triggerLiteral
    ;

triggerLiteral
    : Number
    | StringLiteral
    ;

comparisionOperator
    : GREATERTHAN
    ;

triggerActionExpression
    : KW_KILL
    | KW_MOVE KW_TO poolPath
    ;

triggerActionExpressionStandalone
    : triggerActionExpression EOF
    ;

createTriggerStatement
    : KW_CREATE KW_TRIGGER rpName=id_ DOT triggerName=id_ KW_WHEN triggerExpression KW_DO triggerActionExpression
    ;

alterTriggerStatement
    : KW_ALTER KW_TRIGGER rpName=id_ DOT triggerName=id_ (
        KW_WHEN triggerExpression KW_DO triggerActionExpression
        | (KW_ADD KW_TO | KW_DROP KW_FROM) (KW_POOL poolName=poolPath | KW_UNMANAGED)
    )
    ;

dropTriggerStatement
    : KW_DROP KW_TRIGGER rpName=id_ DOT triggerName=id_
    ;

poolAssign
    : (
        KW_ALLOC_FRACTION EQUAL allocFraction=Number
        | KW_QUERY_PARALLELISM EQUAL parallelism=Number
        | KW_SCHEDULING_POLICY EQUAL policy=StringLiteral
        | KW_PATH EQUAL path=poolPath
    )
    ;

poolAssignList
    : poolAssign (COMMA poolAssign)*
    ;

createPoolStatement
    : KW_CREATE KW_POOL rpName=id_ DOT poolPath KW_WITH poolAssignList
    ;

alterPoolStatement
    : KW_ALTER KW_POOL rpName=id_ DOT poolPath (
        KW_SET poolAssignList
        | KW_UNSET KW_SCHEDULING_POLICY
        | (KW_ADD | KW_DROP) KW_TRIGGER triggerName=id_
    )
    ;

dropPoolStatement
    : KW_DROP KW_POOL rpName=id_ DOT poolPath
    ;

createMappingStatement
    : KW_CREATE mappingType=(KW_USER | KW_GROUP | KW_APPLICATION) KW_MAPPING name=StringLiteral KW_IN rpName=id_ (
        KW_TO path=poolPath
        | unmanaged
    ) (KW_WITH KW_ORDER order=Number)?
    ;

alterMappingStatement
    : KW_ALTER mappingType=(KW_USER | KW_GROUP | KW_APPLICATION) KW_MAPPING name=StringLiteral KW_IN rpName=id_ (
        KW_TO path=poolPath
        | unmanaged
    ) (KW_WITH KW_ORDER order=Number)?
    ;

dropMappingStatement
    : KW_DROP mappingType=(KW_USER | KW_GROUP | KW_APPLICATION) KW_MAPPING name=StringLiteral KW_IN rpName=id_
    ;