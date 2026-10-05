class Torino {
	const property color 
	const property velocidadMaxima
	const property autonomia 

	method capacidad() = 4
	method esRuidoso() = true
	method puedeTransportarSillaDeRuedas() = false
}

class Economico {
	const adaptaciones = #{}
	
	method color() = "beige"
	method puedeTransportarSillaDeRuedas() = adaptaciones.any({adaptador => adaptador.permiteLlevarSillaDeRuedas()})
	method esRuidoso() = !adaptaciones.any({adaptador => adaptador.esSilenciadorDeRuido()})

	method capacidad() = self.capacidadBase() - self.capacidadOcupadaPorAdaptaciones()
	method capacidadBase() = 5
	method capacidadOcupadaPorAdaptaciones() = adaptaciones.sum({adaptador => adaptador.capacidadQueOcupa()})

	method velocidadMaxima() {
		return 
			if (adaptaciones.isEmpty()) { 120 } 
			else {  adaptaciones.min({adaptador => adaptador.velocidadMaxima()}).velocidadMaxima()  }		
	}
	
	method autonomia() = self.autonomiaBase() + self.autonomiaDeLasAdaptaciones()
	method autonomiaBase() = 200
	method autonomiaDeLasAdaptaciones() = adaptaciones.sum({adaptador => adaptador.autonomiaQueAporta()}) 
}

object trasportadorParaSillaDeRuedas{
	method capacidadQueOcupa() = 1
	
	method velocidadMaxima() = 90
	
	method permiteLlevarSillaDeRuedas() = true
	
	method autonomiaQueAporta() = -20
	
	method esSilenciadorDeRuido() = false
}

object cañoDeEscapeSilencioso{
	method capacidadQueOcupa() = 0
	
	method velocidadMaxima() = 115
	
	method permiteLlevarSillaDeRuedas() = false
	
	method autonomiaQueAporta() = -10
	
	method esSilenciadorDeRuido() = true
}

object tanqueExtraDeGas{
	method capacidadQueOcupa() = 1
	
	method velocidadMaxima() = 80

	method permiteLlevarSillaDeRuedas() = false
	
	method autonomiaQueAporta() = 200
	
	method esSilenciadorDeRuido() = true
}

object combiAdaptable{
	var property color = "celeste"
	var property interior = interiorAccesible
	var property motor = deportivo
	
	method capacidad() = interior.capacidadPermitida()
	
	method puedeTransportarSillaDeRuedas() = interior.permiteLlevarSillaDeRuedas()
	
	method velocidadMaxima() = motor.velocidadMaxima()
	
	method autonomia() = motor.autonomia()
	
	method esRuidoso() = motor.esRuidoso()
	
}

object interiorEspacioso{
	method capacidadPermitida() = 7
	
	method permiteLlevarSillaDeRuedas() = false
}
object interiorAccesible{
	method capacidadPermitida() = 5
	
	method permiteLlevarSillaDeRuedas() = true
}

object deportivo{
	method velocidadMaxima() = 230
	
	method autonomia() = 400
	
	method esRuidoso() = true
}
object urbano{
	method velocidadMaxima() = 130
	
	method autonomia() = 1000
	
	method esRuidoso() = false
}


class Reserva {
  const property cantidadDePersonas
  const property distanciaARecorrer
  const property tiempoMaximoDeViajeEnHoras
  const property coloresContraindicados = #{}
  const property necesitaVehiculoSilencioso = false
  const property necesitaSillaDeRuedas = false

  method puedeSerCumplidaPor(vehiculo) =
    self.tieneCapacidadSuficiente(vehiculo) &&
    self.tieneAutonomiaSuficiente(vehiculo) &&
    self.tieneVelocidadSuficiente(vehiculo) &&
    self.respetaNecesidades(vehiculo)

  method tieneCapacidadSuficiente(vehiculo) = vehiculo.capacidad() >= cantidadDePersonas

  method tieneAutonomiaSuficiente(vehiculo) = vehiculo.autonomia() >= distanciaARecorrer

  method tieneVelocidadSuficiente(vehiculo) = vehiculo.velocidadMaxima() >= self.velocidadMinimaRequerida()
  method velocidadMinimaRequerida() = self.velocidadPromedio() + self.margenDeVelocidad()
  method velocidadPromedio() = distanciaARecorrer / tiempoMaximoDeViajeEnHoras
  method margenDeVelocidad() = 10

  method respetaNecesidades(vehiculo) =
    self.respetaColores(vehiculo) &&
    self.respetaSillaDeRuedas(vehiculo) &&
    self.respetaRuido(vehiculo)

  method respetaColores(vehiculo) = !coloresContraindicados.contains(vehiculo.color())
  method respetaSillaDeRuedas(vehiculo) = !necesitaSillaDeRuedas || vehiculo.puedeTransportarSillaDeRuedas()
  method respetaRuido(vehiculo) = !necesitaVehiculoSilencioso || !vehiculo.esRuidoso()
}
	
class Viaje {
  const property reserva
  const property vehiculo

  method distancia() = reserva.distanciaARecorrer()
  method fueRealizadoCon(unVehiculo) = vehiculo == unVehiculo
}

class Sucursal {
  const flota = #{}
  const viajes = []

  method agregarVehiculo(vehiculo) { flota.add(vehiculo) }
  method quitarVehiculo(vehiculo) { flota.remove(vehiculo) }

  method vehiculosCapacesDeCumplir(reserva) =
    flota.filter({vehiculo => reserva.puedeSerCumplidaPor(vehiculo)})

  method registrarViaje(reserva, vehiculo) {
    self.validarQueEsDeLaFlota(vehiculo)
    self.validarQuePuedeCumplir(reserva, vehiculo)
    viajes.add(new Viaje(reserva = reserva, vehiculo = vehiculo))
  }

  method validarQueEsDeLaFlota(vehiculo) {
    if (!flota.contains(vehiculo)) {
      self.error("el vehículo no es parte de la flota de la sucursal")
    }
  }

  method validarQuePuedeCumplir(reserva, vehiculo) {
    if (!reserva.puedeSerCumplidaPor(vehiculo)) {
      self.error("el vehículo no es capaz de cumplir con la reserva indicada")
    }
  }

  method viajesDe(vehiculo) = viajes.filter({viaje => viaje.fueRealizadoCon(vehiculo)})

  method reservasResueltasPor(vehiculo) = self.viajesDe(vehiculo).map({viaje => viaje.reserva()})

  method distanciaTotalRecorridaPor(vehiculo) = self.viajesDe(vehiculo).sum({viaje => viaje.distancia()})
}