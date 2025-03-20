from pyspark.sql import SparkSession

def main():
    spark = SparkSession.builder.appName("Top10CommonWords").getOrCreate()

    # Replace '/path/to/file.txt' with your own file path
    text_rdd = spark.sparkContext.textFile("/path/to/shakesphere.txt")

    # Split each line into words
    words_rdd = text_rdd.flatMap(lambda line: line.split())

    # Map each word to (word, 1) and sum counts
    word_counts_rdd = words_rdd.map(lambda w: (w, 1)).reduceByKey(lambda x, y: x + y)

    # Take the top 10 words with the highest counts
    #   (sort by count descending, i.e. negative of count)
    top_10_words = word_counts_rdd.takeOrdered(10, key=lambda x: -x[1])

    # Print the top 10 words and their counts
    for word, count in top_10_words:
        print(f"{word}: {count}")

    spark.stop()

if __name__ == "__main__":
    main()
