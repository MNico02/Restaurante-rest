package ar.edu.ubp.das.restaurante1.resources;
import ar.edu.ubp.das.restaurante1.beans.*;
import ar.edu.ubp.das.restaurante1.repositories.Restaurante1Repository;
import com.fasterxml.jackson.core.JsonProcessingException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
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



    @GetMapping("/restaurante")
    public ResponseEntity<RestauranteBean> getRestaurante(@RequestParam("id") int id) throws JsonProcessingException {
        RestauranteBean info = restaurante1Repository.getInfoRestaurante(id);
        return ResponseEntity.ok(info);
    }

    @PostMapping("/registrarClicks")
    public ResponseEntity<Map<String, Object>> insertarCicks(@RequestBody List<SoliClickBean> clicks) {
        try {
            for (SoliClickBean c : clicks) {
                restaurante1Repository.insClick(c);
            }
            return ResponseEntity.ok(Map.of("success", true, "message", "Click registrado correctamente"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }





}
