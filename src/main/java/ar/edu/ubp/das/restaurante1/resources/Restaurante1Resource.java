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

    /**
     * guarda en la base de datos del restaurante la reserva que le mando ristorino
     * Recive un reservaBean y devuelvel el codigo de reserva(String)
     * @param reserva
     * @return codReserva
     */
    @PostMapping("/confirmarReserva")
    public ResponseEntity<Map<String, String>> insertarReserva(@RequestBody ReservaBean reserva) {
        String codReserva = restaurante1Repository.insReserva(reserva);
        Map<String, String> response = new HashMap<>();
        response.put("codReserva", codReserva);
        return ResponseEntity.ok(response);
    }

    /**
     * devuelve a ristorino una lista de horarios que dependen de la solicitud hecha por ristorino
     * @param soliHorarioBean
     * @return
     */
    @PostMapping("/consultarDisponibilidad")
    public ResponseEntity<List<HorarioBean>> obtenerHorarios(@RequestBody SoliHorarioBean soliHorarioBean) {
        List<HorarioBean> horarios = restaurante1Repository.getHorarios(soliHorarioBean);
        return ResponseEntity.ok(horarios);
    }


    /**
     * le da a ristorino toda la info del restaurante
     * @param id
     * @return info
     * @throws JsonProcessingException
     */
    @GetMapping("/restaurante")
    public ResponseEntity<RestauranteBean> getRestaurante(@RequestParam("id") int id) throws JsonProcessingException {
        RestauranteBean info = restaurante1Repository.getInfoRestaurante(id);
        return ResponseEntity.ok(info);
    }
    /**
     * inserta en la base de datos una lista de clicks que ristorino le envia por medio del proceso batch.
     * @param clicks
     * @return success true o succes false
     */
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

    @GetMapping("/obtenerPromociones")
    public ResponseEntity<List<ContenidoBean>> getPromociones(@RequestParam("id") int id) throws JsonProcessingException {
        List<ContenidoBean> promociones = restaurante1Repository.getContenidos(id);
        return ResponseEntity.ok(promociones);
    }





}
