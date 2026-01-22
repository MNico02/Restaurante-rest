package ar.edu.ubp.das.restaurante1.beans;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class UpdPublicarContenidosRespBean {
    private String resultado;
    private Integer registrosActualizados;
    private Integer registrosSolicitados;
    private BigDecimal costoAplicado;
}
