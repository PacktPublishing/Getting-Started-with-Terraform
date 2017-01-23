resource "aws_iam_role" "base" {
  name = "base"
  assume_role_policy = "${file("./policies/sts=@assume_role.json")}"
}

resource "aws_iam_instance_profile" "base" {
  name = "base"
  roles = ["${aws_iam_role.base.name}"]
}

resource "aws_iam_policy" "cloudwatch-put-metric" {
  name = "cloudwatch=@put_metric"
  policy = "${file("./policies/cloudwatch=@put_metric.json")}"
}

resource "aws_iam_policy_attachment" "cloudwatch-put-metric-attachment" {
  name = "cloudwatch=@put_metric attachment"
  roles = [ "${aws_iam_role.base.name}" ]
  policy_arn = "${aws_iam_policy.cloudwatch-put-metric.arn}"
}

output "base-role-name" {
  value = "${aws_iam_role.base.name}"
}

