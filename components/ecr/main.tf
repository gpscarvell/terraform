resource "aws_ecr_repository" "ecr_repo" {
  for_each = var.ecr_repos

  name                 = lookup(each.value, "name", null)
  image_tag_mutability = lookup(each.value, "image_tag_mutability", "MUTABLE")

  image_scanning_configuration {
    scan_on_push = lookup(each.value, "scan_on_push", false)
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "ecr_repo_policy" {
  for_each   = var.create_lifecycle_policy ? var.ecr_repos : {}
  repository = aws_ecr_repository.ecr_repo[each.key].name
  policy     = var.ecr_lifecycle_policy
}

resource "aws_ecr_repository_policy" "this" {
  for_each   = var.create_repository_policy ? var.ecr_repos : {}
  repository = aws_ecr_repository.ecr_repo[each.key].name
  policy     = var.repository_policy
}
