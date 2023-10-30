# count
# https://developer.hashicorp.com/terraform/language/meta-arguments/count
locals {
  names = ["test01", "test02"]
}
resource "aws_eip" "default" {
  count = length(local.names)

  tags = {
    Name = local.names[count.index]
  }
}
resource "aws_nat_gateway" "default" {
  count = length(local.names)

  allocation_id = aws_eip.default[count.index].id
  ...
}

# for_each
# https://developer.hashicorp.com/terraform/language/meta-arguments/for_each
locals {
  eips = {
    test01 = {
      role = "web"
    }
    test02 = {
      role = "test"
    }
  }
}
resource "aws_eip" "default" {
  for_each = local.eips

  tags = {
    Name = each.key
    role = each.value["role"]
  }
}
resource "aws_nat_gateway" "default" {
  for_each = local.eips

  allocation_id = aws_eip.default[each.key].id
  ...
}

# https://developer.hashicorp.com/terraform/language/expressions/dynamic-blocks
locals {
  tags = {
    Name = "test01"
    role = "web"
  }
}

resource "aws_autoscaling_group" "default" {

  dynamic "tag" {
    for_each = local.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}


# module
# https://developer.hashicorp.com/terraform/language/modules
# module 用のディレクトリとコードを作成
# ---
variable "name" {
}
variable "subnet_id" {
}

resource "aws_eip" "default" {
  tags = {
    Name = var.name
  }
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.default.id
  subnet_id     = var.subnet_id
}
# ---

# source と variable を指定して利用
# ---
module "test01" {
  source = "./modules/nat"

  name      = "test01"
  subnet_id = "subnet-abcdefg"
}
module "test02" {
  source = "./modules/nat"

  name      = "test02"
  subnet_id = "subnet-bcdefgh"
}
# ---
# count + module
# module を利用する際にも count や for_each で複数セットを作ることが可能です。
locals {
  names = ["test01", "test02"]
}

module "test" {
  count = length(local.names)

  source = "./modules/nat"

  name      = local.names[count.index]
  subnet_id = "subnet-abcdefg"
}

# 条件分岐
# https://developer.hashicorp.com/terraform/language/expressions/conditionals
# 三項演算子
locals {
  flag = true
}

resource "aws_eip" "default" {
  count = local.flag ? 1 : 0
}
# 実行環境ごとに作るか作らないかを制御できます。
locals {
  workspace = terraform.workspace
}

resource "aws_eip" "default" {
  count = local.workspace == "production" ? 1 : 0
}

# 入れ子
locals {
  first  = false
  second = true
  result = local.first ? "A" : (local.second ? "B" : "C")
}
# $ terraform console
# > local.result
# "B"

# ループ構造
# https://developer.hashicorp.com/terraform/language/expressions/for
# for
# list を処理
locals {
  data = ["test01", "test02"]

  result = [for v in local.data: "prefix-${v}"]
}
#$ terraform console
#> local.result
#[
#"prefix-test01",
#"prefix-test02",
#]

# map を list で返したり
locals {
  data = {
    key01 = "value01"
    key02 = "value02"
  }

  result = [for k,v in local.data: "${k}-${v}"]
}

#$ terraform console
#> local.result
#[
#"key01-value01",
#"key02-value02",
#]

# map を編集した map で返したり
locals {
  data = {
    key01 = "value01"
    key02 = "value02"
  }

  result = {for k,v in local.data: v => k}
}

#$ terraform console
#> local.result
#{
#"value01" = "key01"
#"value02" = "key02"
#}

# 入れ子も可能
locals {
  data = {
    key01 = {
      key01_01 = "value01"
      key01_02 = "value02"
    }
    key02 = {
      key02_01 = "value03"
      key02_02 = "value04"
    }
  }

  result = [for k,v in local.data: [for k2,v2 in v: v2]]
}

#$ terraform console
#> local.result
#[
#[
#"value01",
#"value02",
#],
#[
#"value03",
#"value04",
#],
#]
