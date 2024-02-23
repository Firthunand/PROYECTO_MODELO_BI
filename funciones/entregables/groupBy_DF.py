
## from pyspark.sql import SparkSession
## import pyspark.sql.functions as F

def group_df(dataframe, aggregation_dictionary, group_by_columns):
    aggregation_expressions = []
    for column_name, aggregation_info in aggregation_dictionary.items():
        aggregation_type = aggregation_info['type']
        column_to_aggregate = aggregation_info['column']
        if aggregation_type == 'count':
            aggregation_expressions.append(F.count(column_to_aggregate).alias(column_name))
        elif aggregation_type == 'sum':
            aggregation_expressions.append(F.sum(column_to_aggregate).alias(column_name))
    grouped_df = dataframe.groupBy(*group_by_columns).agg(*aggregation_expressions)
    return grouped_df