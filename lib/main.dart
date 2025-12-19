import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(sigApp());
}

class sigApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Center(
        child: SizedBox(
          width: 390,   // ancho móvil (iPhone 12)
          height: 844,  // alto móvil
          child: HomePage(),
        ),
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

enum ModoDibujo { ninguno, punto, linea, poligono }

class _HomePageState extends State<HomePage> {
  final MapController mapController = MapController();

  double zoomActual = 5.0;

  List<Marker> puntos = [];
  List<Polyline> lineas = [];
  List<LatLng> lineaActual = [];
  List<LatLng> poligonoActual = [];
  List<Polygon> poligonos = [];

  ModoDibujo modo = ModoDibujo.ninguno;

  void _zoomMas() {
    zoomActual += 1;
    mapController.move(mapController.camera.center, zoomActual);
  }

  void _zoomMenos() {
    zoomActual -= 1;
    mapController.move(mapController.camera.center, zoomActual);
  }

  void _onTapMapa(TapPosition tapPos, LatLng pos) {
    switch (modo) {
      case ModoDibujo.punto:
        _crearPunto(pos);
        print("Hiciste click en la coordenada $pos");
        break;
      case ModoDibujo.linea:
        _agregarPuntoLinea(pos);
        break;
      case ModoDibujo.poligono:
        _agregarPuntoPoligono(pos);
        break;
      case ModoDibujo.ninguno:
        break;
    }
  }

  void _crearPunto(LatLng pos) {
    puntos.add(
      Marker(
        point: pos,
        width: 80,
        height: 80,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 35),
      ),
    );
    setState(() {});
  }

  void _agregarPuntoLinea(LatLng pos) {
    lineaActual.add(pos);
    if (lineaActual.length > 1) {
      lineas.add(
        Polyline(
          points: List.from(lineaActual),
          color: Colors.blue,
          strokeWidth: 2,
        ),
      );
    }
    setState(() {});
  }

  void _finalizarLinea() {
    lineas.clear();
    lineaActual.clear();
    setState(() {});
  }

  void _agregarPuntoPoligono(LatLng pos) {
    poligonoActual.add(pos);
    if (poligonoActual.length > 2) {
      poligonos.add(
        Polygon(
          points: List.from(poligonoActual),
          color: Colors.orange.withOpacity(0.3),
          borderColor: Colors.red,
          borderStrokeWidth: 2,
        ),
      );
    }
    setState(() {});
  }

  void _finalizarPoligono() {
    poligonos.clear();
    if (poligonoActual.length > 2) {
      poligonos.add(
        Polygon(
          points: List.from(poligonoActual),
          color: Colors.orange.withOpacity(0.3),
          borderColor: Colors.green,
          borderStrokeWidth: 2,
        ),
      );
    }

    poligonoActual.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App - SIG")),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(-17, -65),
              initialZoom: zoomActual,
              onTap: _onTapMapa,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.sig',
                // + many other options
              ),
              MarkerLayer(markers: puntos),
              PolylineLayer(polylines: lineas),
              PolygonLayer(polygons: poligonos),
            ],
          ),
          Positioned(
            left: 15,
            top: 20,

            child: Column(
              children: [
                SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  heroTag: "CrearPunto",
                  backgroundColor: modo == ModoDibujo.punto
                      ? Colors.green
                      : Colors.grey,
                  onPressed: () {
                    setState(() {
                      if (modo == ModoDibujo.punto) {
                        modo =
                            ModoDibujo.ninguno; // desactiva si ya estaba activo
                      } else {
                        modo = ModoDibujo.punto; // activa si estaba desactivado
                      }
                    });
                  },

                  child: Icon(Icons.location_on),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  heroTag: "CrearLinea",
                  backgroundColor: modo == ModoDibujo.linea
                      ? Colors.green
                      : Colors.grey,
                  onPressed: () {
                    setState(() {
                      if (modo == ModoDibujo.linea) {
                        modo =
                            ModoDibujo.ninguno; // desactiva si ya estaba activo
                      } else {
                        modo = ModoDibujo.linea; // activa si estaba desactivado
                      }
                    });
                  },

                  child: Icon(Icons.timeline),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  heroTag: "CrearPoligono",
                  backgroundColor: modo == ModoDibujo.poligono
                      ? Colors.green
                      : Colors.grey,
                  onPressed: () {
                    setState(() {
                      if (modo == ModoDibujo.poligono) {
                        modo =
                            ModoDibujo.ninguno; // desactiva si ya estaba activo
                      } else {
                        modo =
                            ModoDibujo.poligono; // activa si estaba desactivado
                      }
                    });
                  },

                  child: Icon(Icons.play_arrow_outlined),
                ),
              ],
            ),
          ),
          Positioned(
            left: 15,
            bottom: 40,

            child: Column(
              children: [
                const SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  heroTag: "FinalizarLinea",
                  backgroundColor: Colors.blue,
                  onPressed: _finalizarLinea,
                  child: Icon(Icons.check),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  heroTag: "FinalizarPoligono",
                  backgroundColor: Colors.orange,
                  onPressed: _finalizarPoligono,
                  child: Icon(Icons.pan_tool_outlined),
                ),
              ],
            ),
          ),
          Positioned(
            right: 15,
            bottom: 40,

            child: Column(
              children: [
                SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  heroTag: "ZoomMas",
                  onPressed: _zoomMas,
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  mini: true,
                  heroTag: "ZoomMenos",
                  onPressed: _zoomMenos,
                  child: Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
