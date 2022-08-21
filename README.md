# Puntos extras

**1) Como expondrias tu aplicacion a internet**:
Se cambiaria la subnet privada por una publica y se cofiguraria los demas servicios necesarios, internet gateway y la routables.

**2) Que utilizarias para escalar tu aplicacion de manera dinamica**: Implementaria un load balancer si se requiere mantener en este momento los ec2, pero igual se pudiera hacer hacia un fargate o un cluster y orkestador como kubernetes. 
O cambiar la arquitectura de microservicios a lambdas.

**3) Como darias acceso a un desarrollador a la base de datos**: Se crearia un bastion para el acceso corerspondiente y asi poderse conectar al gestor mediante una coneccion ssh o en su defecto igual implementar una vpn para el ascceso.


Nueva Arquitectura


![Arquitectura nueva](./img/Screenshot%20from%202022-08-21%2009-39-56.png)
