class Mensaje {
  const tipoDeContenido
  var property emisor   // Un mensaje tiene un emisor 

  method peso() = 5 + tipoDeContenido.peso() * 1.3 

  // 3)
  // 2. Un mensaje contiene un texto si es parte del nombre de quien lo envía, si es parte del texto del mensaje, 
  // o del nombre del contacto enviado

  // Los strings entienden el mensaje contains(otroTexto) que indica si el parámetro se encuentra dentro del string.

  method contiene(texto) =  emisor.contiene(texto) or tipoDeContenido.contiene(texto) 

}

// -------- TIPOS DE CONTENIDOS ---------

class TipoTexto {
  const elTexto

  method peso() = elTexto.size()

  method contiene(texto) = elTexto.contains(texto) 
}

class TipoAudio {
  const duracion

  method peso() = 1.2 * duracion

  method contiene(texto) = false  // un Audio no contiene texto!! 
}

class TipoContacto {
  const usuario   // Se debe saber qué usuario se envía

  method peso() = 3

  method contiene(texto) = usuario.contains(texto)
}

class TipoImagen {
  const alto
  const ancho
  var modoDeCompresion 
  const pesoPixel = 2

  method cantidadPixeles() = alto * ancho

  // el peso de la imagen/gifs depende de la cantidad de pixeles que envie el tipo de compresion
  method peso() = modoDeCompresion.pixelesAEnviar(self.cantidadPixeles()) * pesoPixel

  method contiene(texto) = false  // una Imagen no contiene texto!!
}

class TipoGif inherits TipoImagen {
  const cantidadCuadros

  override method peso() = super() * cantidadCuadros
}

// -------- MODOS DE COMPRESION ---------

object compresionOriginal {
  method pixelesAEnviar(cantidad) = cantidad 
}

class CompresionVarible {
  const porcentaje
  method pixelesAEnviar(cantidad) = porcentaje * cantidad
}

object compresionMaxima {
  method pixelesAEnviar(cantidad) = 10000.min(cantidad)   // cantidad.min(10000)
}

// -------- CHATEANDO ---------

class Chat {
  const mensajes = []
  const participantes = []

  method cantidadMensajes() = mensajes.size() 
  method contieneElMensaje(mensaje) = mensajes.contains(mensaje)  

  // 1) Saber el espacio que ocupa un chat, que es la suma de los pesos de los mensajes enviados.
  method espacioOcupado() = mensajes.sum({mensaje => mensaje.peso()})

  // 2) Enviar un mensaje a un chat considerando los tipos de chats y las restricciones que tienen. 

  method enviarMensaje(mensaje){                  // Pero ojo, no se puede enviar un mensaje a cualquier chat.
    self.validarEnvio(mensaje)                    // 1°) El emisor del mensaje debe estar entre los participantes del chat. 
    //self.tienenEspacioSuficientePara(mensaje)   // 2°) Es necesario que cada participante tenga espacio libre suficiente para almacenar el mensaje
    self.notificarMensaje(mensaje)                // X°) Al enviar un mensaje a un chat cada participante debe recibir una notificación.
    mensajes.add(mensaje)                         // 3°) Agrego el mensaje a la lista de mensajes del chat (TIENE EFECTO)
  }

  method validarEnvio(mensaje) {
    if(!self.puedeEnviarse(mensaje)){
      throw new DomainException(message = "No se puede enviar el mensaje")
    }
  } 

  method puedeEnviarse(mensaje) = participantes.contains(mensaje.emisor()) and self.tienenEspacioSuficientePara(mensaje)

  method tienenEspacioSuficientePara(mensaje) = participantes.all({participante => participante.tieneEspacioSufientePara(mensaje)})

  method esParteDelChat(persona) = participantes.contains(persona)

  // 3)
  // 2. Un mensaje contiene un texto si es parte del nombre de quien lo envía, si es parte del texto del mensaje, 
  // o del nombre del contacto enviado
  method contiene(texto) = mensajes.any({mensaje => mensaje.contiene(texto)})

  // 4)  
  method mensajeMasPesado() = mensajes.max({mensaje => mensaje.peso()})

  // 5)
  method notificarMensaje(mensaje) {
    participantes.forEach({participante => participante.notificar(new Notificacion(chat = self))})
  }

}

class ChatPremiun inherits Chat {
  const creador
  var permiso

  override method puedeEnviarse(mensaje) = super(mensaje) and permiso.puedeEnviarAdional(mensaje, creador, self) 
}

// -------- TIPOS DE PERMISOS ---------

object difusion { 
  // Difusion: solamente el creador del chat premium puede enviar mensajes.(el que envia mensajes es el emisor del mismo)
  method puedeEnviarAdional(mensaje, creador, chat) = mensaje.emisor() == creador
}

class Restringido {
  // Determina un límite de mensajes que puede tener el chat, una vez llegada a esa cantidad no deja enviar más mensajes.
  const limiteMensajes
  
  method puedeEnviarAdicional(mensaje, creador, chat) = chat.cantidadMensajes() <= limiteMensajes
}

class Ahorro {
  // Ahorro: todos los integrantes pueden enviar solamente mensajes que no superen un peso máximo determinado.
  const pesoMaximo

  method puedeEnviarAdicional(mensaje, creador, chat) = mensaje.peso() <= pesoMaximo
}


class Usuario {
  const nombre
  const memoria  
  const chats = []            // Los usuarios tienen una memoria que se va llenando con cada mensaje
  const notificaciones = []   // Los usuarios tienen notificaciones de mensajes sin leer

  method agregarChat(chat) {
    chats.add(chat)
  }

  method espacioOcupado() = chats.sum({chat => chat.espacioOcupado()})
  
  method tieneEspacioSufientePara(mensaje) = self.espacioOcupado() + mensaje.peso() <= memoria

  // 3) Hacer una búsqueda de un texto en los chats de un usuario.
  // - 1. La búsqueda obtiene como resultado los chats que tengan algún mensaje con ese texto. 
  // - 2. Un mensaje contiene un texto si es parte del nombre de quien lo envía, si es parte del texto del mensaje, 
  // - o del nombre del contacto enviado

  // 1.
  method buscarTexto(texto) = chats.filter({chat => chat.contiene(texto)}) 

  method contiene(texto) = nombre.contains(texto)

  // 4) Dado un usuario, conocer sus mensajes más pesados. 
  // - Que es el conjunto formado por el mensaje más pesado de cada uno de sus chat.

  method mensajesMasPesados() = chats.map({chat => chat.mensajeMasPesado()})

  // 5) Los usuarios también son notificados de sus chats sin leer.
  //  a) Al enviar un mensaje a un chat cada participante debe recibir una notificación.
  //  b) Que un usuario pueda leer un chat. Al leer un chat, todas las notificaciones del usuario correspondiente a ese chat se marcan como leídas.
  //  c) Conocer las notificaciones sin leer de un usuario.

  // 5.a)
  method notificar(notificacion) {
    notificaciones.add(notificacion)
  }

  // 5.b)
  method leerUn(elChat){
    self.notificacionesDeUnChat(elChat).forEach({notificacion => notificacion.leida(true)})
  }

  method notificacionesDeUnChat(elChat) = notificaciones.filter({notificacion => notificacion.chat() == elChat})

  // 5.c)
  method notificacionesSinLeer() = notificaciones.filter({notificacion => !notificacion.leida()})

}

class Notificacion {
  const property chat        // la notificacion tiene un chat ("viene de un chat")
  var property leida = false // una notificacion por default se inical como no leida

  //method chat() = chat
  method leer(){ leida = true }
}

