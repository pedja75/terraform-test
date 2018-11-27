resource "aws_lb_target_group" "TG_test" {
  name     = "Test-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc_test01.id}"
}

resource "aws_lb_target_group_attachment" "TG_test_attachment_01" {
  target_group_arn = "${aws_lb_target_group.TG_test.arn}"
  target_id        = "${aws_instance.ec2_test01.id}"
  port             = 80
}
resource "aws_lb_target_group_attachment" "TG_test_attachment_02" {
  target_group_arn = "${aws_lb_target_group.TG_test.arn}"
  target_id        = "${aws_instance.ec2_test02.id}"
  port             = 80
}
