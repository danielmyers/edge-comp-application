resource "aws_dynamodb_table" "movies-table" {
  name         = "movies"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "movieId"

  attribute {
    name = "movieId"
    type = "N"
  }

  attribute {
    name = "title"
    type = "S"
  }

  attribute {
    name = "genres"
    type = "S"
  }

  global_secondary_index {
    name            = "title-index"
    hash_key        = "title"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "genres-index"
    hash_key        = "genres"
    projection_type = "ALL"
  }

  tags = {
    Name        = "movies_table_dynamodb"
    Project     = "Movies"
    Environment = "production"
  }
}

resource "aws_dynamodb_table" "ratings-table" {
  name         = "ratings"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "movieId"
  range_key    = "userId"

  attribute {
    name = "movieId"
    type = "N"
  }

  attribute {
    name = "userId"
    type = "N"
  }

  attribute {
    name = "rating"
    type = "N"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  global_secondary_index {
    name            = "rating-index"
    hash_key        = "movieId"
    range_key       = "rating"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "timestamp-index"
    hash_key        = "movieId"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  tags = {
    Name        = "ratings_table_dynamodb"
    Project     = "Movies"
    Environment = "production"
  }
}

resource "aws_dynamodb_table" "tags-table" {
  name         = "tags"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "movieId"
  range_key    = "user_tag_composite"

  attribute {
    name = "movieId"
    type = "N"
  }

  attribute {
    name = "user_tag_composite"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "N"
  }

  attribute {
    name = "tag"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  global_secondary_index {
    name            = "userId-index"
    hash_key        = "movieId"
    range_key       = "userId"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "tag-index"
    hash_key        = "movieId"
    range_key       = "tag"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "timestamp-index"
    hash_key        = "movieId"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  tags = {
    Name        = "tags_table_dynamodb"
    Project     = "Movies"
    Environment = "production"
  }

}