package ar.edu.ubp.das.restaurante1.resources;
import ar.edu.ubp.das.restaurante1.beans.HorarioBean;
import ar.edu.ubp.das.restaurante1.beans.ReservaBean;
import ar.edu.ubp.das.restaurante1.beans.SoliHorarioBean;
import ar.edu.ubp.das.restaurante1.repositories.Restaurante1Repository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/restaurante1")
public class Restaurante1Resource {

    @Autowired
    private Restaurante1Repository restaurante1Repository;

    @PostMapping("/confirmarReserva")
    public ResponseEntity<String> insertarReserva(@RequestBody ReservaBean reserva) {
        String codReserva = restaurante1Repository.insReserva(reserva);
        return ResponseEntity.ok(codReserva);
    }
    @GetMapping("/consultarDisponibilidad")
    public ResponseEntity<List<HorarioBean>> obtenerHorarios(@RequestBody SoliHorarioBean soliHorarioBean) {
        List<HorarioBean> horarios = restaurante1Repository.getHorarios(soliHorarioBean);
        return ResponseEntity.ok(horarios);
    }


   /* @GetMapping("/provincias/{codPais}")
    public ResponseEntity<List<ProvinciaBean>> obtenerProvincias(@PathVariable String codPais) {
        List<ProvinciaBean> provincias = localidadesRepository.getProvincias(codPais);
        return ResponseEntity.ok(provincias);
    }

    @PostMapping("/localidades")
    public ResponseEntity<List<LocalidadBean>> obtenerLocalidades(@RequestBody LocalidadCriteriaBean criteria) {
        List<LocalidadBean> localidades = localidadesRepository.getLocalidades(criteria);
        return ResponseEntity.ok(localidades);
    }

    @PutMapping("/localidad")
    public ResponseEntity<LocalidadBean> insertarLocalidad(@RequestBody LocalidadBean localidad) {
        LocalidadBean updatedLocalidad = localidadesRepository.insLocalidad(localidad);
        return ResponseEntity.ok(updatedLocalidad);
    }*/

}
