package ar.edu.ubp.das.restaurante1.resources;
import ar.edu.ubp.das.restaurante1.beans.HorarioBean;
import ar.edu.ubp.das.restaurante1.beans.ReservaBean;
import ar.edu.ubp.das.restaurante1.beans.RestauranteBean;
import ar.edu.ubp.das.restaurante1.beans.SoliHorarioBean;
import ar.edu.ubp.das.restaurante1.repositories.Restaurante1Repository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/restaurante1")
public class Restaurante1Resource {

    @Autowired
    private Restaurante1Repository restaurante1Repository;

    @PostMapping("/confirmarReserva")
    public ResponseEntity<Map<String, String>> insertarReserva(@RequestBody ReservaBean reserva) {
        String codReserva = restaurante1Repository.insReserva(reserva);
        Map<String, String> response = new HashMap<>();
        response.put("codReserva", codReserva);
        return ResponseEntity.ok(response);
    }
    @GetMapping("/consultarDisponibilidad")
    public ResponseEntity<List<HorarioBean>> obtenerHorarios(@RequestBody SoliHorarioBean soliHorarioBean) {
        List<HorarioBean> horarios = restaurante1Repository.getHorarios(soliHorarioBean);
        return ResponseEntity.ok(horarios);
    }
    /*@GetMapping("/consultarRestaurante")
    public ResponseEntity<RestauranteBean> obtenerRestaurantes() {
        RestauranteBean restaurante = restaurante1Repository.getRestaurantes();
        return ResponseEntity.ok(restaurante);
    }*/


}
