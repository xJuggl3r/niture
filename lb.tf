/* Cria Load Balancer lb1 */

resource "oci_load_balancer" "lb1" {
  shape          = "100Mbps"
  compartment_id = var.compartment_ocid

  subnet_ids = [
    oci_core_subnet.tcb_subnet.id,
  ]

  display_name               = "lb1"
  is_private                 = false
  #network_security_group_ids = [oci_core_network_security_group.test_network_security_group.id]
}

/* Cria Backend Set no Load Balancer */
resource "oci_load_balancer_backend_set" "lb-bes1" {
  name             = "lb-bes1"
  load_balancer_id = oci_load_balancer.lb1.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }

  session_persistence_configuration {
    cookie_name      = "lb-session1"
    disable_fallback = true
  }
}

## Exemplo Listener
#resource "oci_load_balancer_listener" "test_listener" {
#    #Required
#    default_backend_set_name = oci_load_balancer_backend_set.test_backend_set.name
#    load_balancer_id = oci_load_balancer_load_balancer.test_load_balancer.id
#    name = var.listener_name
#    port = var.listener_port
#    protocol = var.listener_protocol

#    connection_configuration {
        #Required
#        idle_timeout_in_seconds = var.listener_connection_configuration_idle_timeout_in_seconds
#    }
#}

/* Cria Lister no Load Balancer */
resource "oci_load_balancer_listener" "lb-listener1" {
  load_balancer_id         = oci_load_balancer.lb1.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb-bes1.name
  #hostname_names           = [oci_load_balancer_hostname.test_hostname1.name, oci_load_balancer_hostname.test_hostname2.name]
  port                     = 80
  protocol                 = "HTTP"
  #rule_set_names           = [oci_load_balancer_rule_set.test_rule_set.name]

  connection_configuration {
    idle_timeout_in_seconds = "10"
  }
}

/* Adiciona Webserver1 Backend no Load Balancer */
resource "oci_load_balancer_backend" "lb-be1" {
  load_balancer_id = oci_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-bes1.name
  ip_address       = oci_core_instance.webserver1.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

/* Adiciona Webserver2 Backend no Load Balancer */
resource "oci_load_balancer_backend" "lb-be2" {
  load_balancer_id = oci_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-bes1.name
  ip_address       = oci_core_instance.webserver2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}