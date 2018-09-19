terraform {
  required_version = ">= 0.9.3, != 0.9.5"
}

# Configure AWS Provider
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "template_file" "run_install_ucp" {
  template = "${file("./files/run_install_ucp.tpl")}"
  vars = {
    ucp_version = "${var.ucp_version}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
}

data "template_file" "run_install_worker" {
  template = "${file("./files/run_install_worker.tpl")}"
  vars = {
    ucp_version = "${var.ucp_version}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
}
resource "aws_instance" "manager" {
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type_manager}"
    count = 1
    key_name = "${var.ssh_key_name}"

    security_groups =  ["${aws_security_group.allow_all.name}"]

    connection {
        type        = "ssh"
        user        = "${var.provisioning_user}"
        private_key = "${file("${var.provisioning_key}")}"
    }

    provisioner "file" {
        source = "./files/install_ucp.sh"
        destination = "/tmp/install_ucp.sh"
    }

    provisioner "file" {
        content     = "${data.template_file.run_install_ucp.rendered}"
        destination = "/tmp/run_install_ucp.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/run_install_ucp.sh",
            "/tmp/run_install_ucp.sh ${count.index} ${self.private_ip} ${aws_instance.manager.0.private_ip} ${aws_instance.manager.0.public_dns}"
        ]
    }

    provisioner "local-exec" {
        command = "./files/local-tests.sh ${aws_instance.manager.0.public_dns} ${var.admin_username} ${var.admin_password}"
    }
}

resource "aws_instance" "worker" {
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type_manager}"
    count = 1
    key_name = "${var.ssh_key_name}"

    security_groups =  ["${aws_security_group.allow_all.name}"]

    connection {
        type        = "ssh"
        user        = "${var.provisioning_user}"
        private_key = "${file("${var.provisioning_key}")}"
    }

    provisioner "file" {
        source = "./files/install_worker.sh"
        destination = "/tmp/install_worker.sh"
    }

    provisioner "file" {
        content     = "${data.template_file.run_install_worker.rendered}"
        destination = "/tmp/run_install_worker.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/run_install_worker.sh",
            "/tmp/run_install_worker.sh ${count.index} ${self.private_ip} ${aws_instance.manager.0.private_ip} ${aws_instance.manager.0.public_dns}"
        ]
    }
}


resource "aws_security_group" "allow_all" {
    description = "Allow all inbound traffic"

    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags {
        Name = "allow_all"
    }
}
