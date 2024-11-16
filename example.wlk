class Mensaje {
  const tipoDeContenido

  method peso() = 5 + tipoDeContenido.peso() * 1.3 

}

// -------- CONTENIDOS ---------

class TipoTexto {
  const elTexto

  method peso() = elTexto.size()
}

class TipoAudio {
  const duracion

  method peso() = 1.2 * duracion
}

class TipoContacto {
  const usuario   // Se debe saber qué usuario se envía

  method peso() = 3
}

class TipoImagen {
  const alto
  const ancho
  var modoDeCompresion = compresionOriginal
  const pesoPixel = 2

  method cantidadPixeles() = alto * ancho

  // el peso de la imagen/gifs depende de la cantidad de pixeles que envie el tipo de compresion
  method peso() = modoDeCompresion.pixelesAEnviar(self.cantidadPixeles()) * pesoPixel
}

class TipoGif inherits TipoImagen {
  const cantidadCuadros

  override method peso() = super() * cantidadCuadros
}

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

