# create Iam role to be used by EC2-instance
resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2_instance_role"
  assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
              Sid = ""
              Action = "sts:AssumeRole"
              Effect = "Allow"
              Principal = {
                  Service = "ec2.amazonaws.com"
              }
        },
      ]
  })

  tags = merge (
      var.tags,
      {
          Name = "aws assume role"
      }
  )
}

# create an iam policy to be attached to the iam role
resource "aws_iam_policy" "policy" {
  name        = "ec2_instance_policy"
  description = "A test policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]

  })

  tags = merge(
    var.tags,
    {
      Name =  "aws assume policy"
    },
  )
}

# attach the iam_policy to the iam role 
resource "aws_iam_role_policy_attachment" "test_attach" {
    role = aws_iam_role.ec2_instance_role.name
    policy_arn = aws_iam_policy.policy.arn
}

#create an instance profile to pass an iam role to an ec2 instance
resource "aws_iam_instance_profile" "instProfile" {
    name = "aws_instance_profile_test"
    role = aws_iam_role.ec2_instance_role.name
}