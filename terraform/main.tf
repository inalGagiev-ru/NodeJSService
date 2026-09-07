terraform {
    required_providers {
        yandex = {
            source = "yandex-cloud/yandex"
            version = "0.115.0"
        }
    }
}

provider "yandex" {
    token = var.yc_token
    cloud_id  = var.cloud_id
    folder_id = var.folder_id
    zone = "ru-central1-a"
}

variable "yc_token" {
    description = "Yandex Cloud OAuth Token"
    type = string
    sensitive = true #терраформ не будет выводить эту переменную в консоль при plan, apply
}

variable "cloud_id" {
    description = "Yandex Cloud ID"
    type = string
}

variable "folder_id" {
    description = "Yandex Folder ID"
    type = string
}





resource "yandex_vpc_network" "my_network" {
    name = "my-terraform-network"
}

resource "yandex_vpc_subnet" "my_subnet" {
    name = "my-terraform-subnet"
    zone = "ru-central1-a"
    network_id = yandex_vpc_network.my_network.id
    v4_cidr_blocks = ["192.168.10.0/24"]
}

data "yandex_compute_image" "ubuntu" {
    family = "ubuntu-2204-lts"
}





resource "yandex_compute_instance" "my_vm" {
    name = "my-terraform-vm-1"
    zone = "ru-central1-a"

    resources {
        cores = 2
        memory = 2
    }

    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.ubuntu.id
        }
    }

    network_interface {
        subnet_id = yandex_vpc_subnet.my_subnet.id
        nat = true
    }

    metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
}

output "vm_public_ips" {
    value = yandex_compute_instance.my_vm.network_interface[0].nat_ip_address
}