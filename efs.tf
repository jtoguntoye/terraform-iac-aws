#create kms key to be used to encrypt the EFS and RDS storage
resource "aws_kms_key" "kiff-kms-key" {
    description = "KMS key 1"
    policy      = <<EOF
    {
        "Version": "2012-10-17",
        "Id": "kms-key-policy",
        "Statement": [
            {
                "Sid": "Enable IAM User Permissions",
                "Effect": "Allow",
                "Principal": { "AWS": "arn:aws:iam::${var.account_no}:user/devops" },
                "Action": "kms:*",
                "Resource": "*"
            }
        ]
    }
    EOF
}

# create key alias
resource "aws_kms_alias" "alias" {
    name = "alias/kms"
    target_key_id = aws_kms_key.kiff-kms-key.key_id

}


#--- create elastic file sytem ---
resource "aws_efs_file_system" "kiff-efs" {
    encrypted = true
    kms_key_id  =aws_kms_key.kiff-kms-key.arn

    tags =  merge(
        var.tags,
        {
            Name = "Kiff-efs"
        },
    )
}

# set the first mount target for the efs 
resource "aws_efs_mount_target" "mount-subnet-a" {
    file_system_id = aws_efs_file_system.kiff-efs.id
    subnet_id =  aws_subnet.private-A[0].id
    security_groups = [aws_security_group.datalayer-sg.id]
} 

# set the second mount target for the efs 
resource "aws_efs_mount_target" "mount-subnet-b" {
    file_system_id = aws_efs_file_system.kiff-efs.id
    subnet_id =  aws_subnet.private-A[1].id
    security_groups = [aws_security_group.datalayer-sg.id]
} 

# create access point for wordpress
resource "aws_efs_access_point" "wordpress" {
    file_system_id = aws_efs_file_system.kiff-efs.id

    posix_user {
        gid = 0
        uid = 0
    }

    root_directory {
        path = "/wordpress"

        creation_info {
            owner_gid = 0
            owner_uid = 0
            permissions = 0755
        }
    }
}



# create access point for tooling
resource "aws_efs_access_point" "tooling" {
    file_system_id = aws_efs_file_system.kiff-efs.id

    posix_user {
        gid = 0
        uid = 0
    }

    root_directory {
        path = "/tooling"

        creation_info {
            owner_gid = 0
            owner_uid = 0
            permissions = 0755
        }
    }
}
