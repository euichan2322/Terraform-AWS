resource "aws_iam_user" "test-user-iam" {
  name = "test-user1"
}

resource "aws_iam_group" "test-group" {
  name = "test-group"
}

resource "aws_iam_user_group_membership" "test-membership" {
  user = aws_iam_user.test-user-iam.name
  groups = [
    aws_iam_group.test-group.name
  ]  
}

resource "aws_iam_role" "test-role" {
  name = "test-role"

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
}

resource "aws_iam_policy" "test-iam-policy" {
  name        = "test-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.test-role.name
  policy_arn = aws_iam_policy.test-iam-policy.arn
}
