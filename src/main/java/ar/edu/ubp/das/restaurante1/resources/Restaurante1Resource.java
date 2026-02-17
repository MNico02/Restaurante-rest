package ar.edu.ubp.das.restaurante1.resources;
import ar.edu.ubp.das.restaurante1.beans.*;
import ar.edu.ubp.das.restaurante1.repositories.Restaurante1Repository;
//import ar.edu.ubp.das.restaurante1.service.ReservaService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.nimbusds.jose.shaded.gson.Gson;
import com.nimbusds.jose.shaded.gson.JsonObject;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/restaurante1")
public class Restaurante1Resource {

    @Autowired
    private Restaurante1Repository restaurante1Repository;
    /*@Autowired
    private ReservaService reservaService;*/


    /**
     * le da a ristorino toda la info del restaurante
     * @return info
     * @throws JsonProcessingException
     */
    @GetMapping("/restaurante")
    public ResponseEntity<RestauranteBean> getRestaurante() throws JsonProcessingException {
        RestauranteBean info = restaurante1Repository.getInfoRestaurante();
        return ResponseEntity.ok(info);
    }

    /**
     * guarda en la base de datos del restaurante la reserva que le mando ristorino
     * Recive un reservaBean y devuelvel el codigo de reserva(String)
     * @param
     * @return codReserva
     */
    @PostMapping("/confirmarReserva")
    public ResponseEntity<ConfirmarReservaResponse> confirmarReserva(@RequestBody String jsonRequest) {

        ConfirmarReservaResponse resp = restaurante1Repository.insReserva(jsonRequest);

        if (resp.isSuccess()) {
            return ResponseEntity.ok(resp);
        }

        // Si querés, diferenciás validación rápida vs negocio (cupo) por mensaje o por códigos
        String msg = (resp.getMensaje() == null) ? "" : resp.getMensaje().toLowerCase();

        if (msg.contains("inválida") || msg.contains("obligatorio") || msg.contains("incomplet")) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(resp);
        }

        return ResponseEntity.status(HttpStatus.CONFLICT).body(resp);
    }

    @PostMapping("/modificarReserva")
    public ResponseEntity<ResponseBean> modificarReserva(@RequestBody String jsonRequest) {

        ResponseBean resp = restaurante1Repository.modificarReserva(jsonRequest);


        return ResponseEntity.ok(resp);

    }


    /**
     * devuelve a ristorino una lista de horarios que dependen de la solicitud hecha por ristorino
     * @return
     */
    @PostMapping("/consultarDisponibilidad")
    public ResponseEntity<List<HorarioBean>> obtenerHorarios(@RequestBody String jsonRequest) {
        List<HorarioBean> horarios = restaurante1Repository.getHorarios(jsonRequest);
        return ResponseEntity.ok(horarios);
    }

    @PostMapping("/cancelarReserva")
    public ResponseEntity<Map<String, Object>> cancelarReserva(@RequestBody String jsonRequest) {
        //al repo le pasamos un parametro y no el json. Desarmamos el json aca para poder hacer una comprobacion
        Gson gson = new Gson();
        JsonObject json = gson.fromJson(jsonRequest, JsonObject.class);
        String cod = json.get("codReservaSucursal").getAsString();
        if (cod == null || cod.isBlank() || "null".equalsIgnoreCase(cod)) {
            return ResponseEntity.badRequest().body(
                    Map.of("success", false, "status", "ERROR", "message", "codReservaSucursal es obligatorio.")
            );
        }

        try {
            Map<String, Object> rta = restaurante1Repository.cancelarReservaPorCodigoSucursal(cod);
            return ResponseEntity.ok(rta);

        } catch (Exception e) {
            return ResponseEntity.status(500).body(
                    Map.of("success", false, "status", "ERROR", "message", "Error al cancelar: " + e.getMessage())
            );
        }
    }



    /**
     * inserta en la base de datos una lista de clicks que ristorino le envia por medio del proceso batch.

     * @return success true o succes false
     */
    @PostMapping("/registrarClicks")
    public ResponseBean insertarCicks(@RequestBody String jsonRequest) {
        try {
            String resultado =    restaurante1Repository.insClickLote(jsonRequest);
            System.out.println(resultado);
            ResponseBean resp = new ResponseBean();
            resp.setSuccess(true);
            resp.setMessage(resultado);
            resp.setStatus("OK");
            return resp;
        } catch (Exception e) {
            ResponseBean resp = new ResponseBean();
            resp.setSuccess(false);
            resp.setMessage( e.getMessage());
            resp.setStatus("ERROR");
            return resp;
        }
    }

    @GetMapping("/obtenerPromociones")
    public ResponseEntity<List<ContenidoBean>> getPromociones() throws JsonProcessingException {
        List<ContenidoBean> promociones = restaurante1Repository.getContenidos();
        return ResponseEntity.ok(promociones);
    }
    @PostMapping("/notificarRestaurante")
    public ResponseEntity<UpdPublicarContenidosRespBean> notificarRestaurante(@RequestBody String jsonRequest) {
        UpdPublicarContenidosRespBean resp =
                restaurante1Repository.notificarContenidos(jsonRequest);

        if (resp == null) {

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .build();
        }
        System.out.println("SP upd_publicar_contenidos_lote -> resultado: "+resp.getResultado()+
                ", actualizados: "+resp.getRegistrosActualizados()+"/"+resp.getRegistrosSolicitados());
        return ResponseEntity.ok(resp);

    }





}