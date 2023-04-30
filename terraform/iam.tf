resource "aws_iam_role" "movies_instance_role" {
  name = "movies_instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Project = "movies"
  }
}

resource "aws_iam_role_policy" "movies_instance_policy" {
  name = "movies_instance_policy"
  role = aws_iam_role.movies_instance_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue"
      ],
      "Effect": "Allow",
      "Resource": "<Secret ARN>"
    }
  ]
}
EOF
}