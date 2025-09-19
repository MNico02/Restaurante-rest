package ar.edu.ubp.das.restaurante1.repositories;
import ar.edu.ubp.das.restaurante1.beans.HorarioBean;
import ar.edu.ubp.das.restaurante1.beans.ReservaBean;
import ar.edu.ubp.das.restaurante1.beans.RestauranteBean;
import ar.edu.ubp.das.restaurante1.beans.SoliHorarioBean;
import ar.edu.ubp.das.restaurante1.components.SimpleJdbcCallFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;

import java.sql.Types;
import java.util.List;
import java.util.Map;

@Repository
public class Restaurante1Repository {

    @Autowired
    private SimpleJdbcCallFactory jdbcCallFactory;

    public String insReserva(ReservaBean data) {
        SqlParameterSource params = new MapSqlParameterSource()
                .addValue("nro_cliente", null, Types.INTEGER)
                .addValue("apellido", data.getApellido())
                .addValue("nombre", data.getNombre())
                .addValue("correo", data.getCorreo())
                .addValue("telefonos", data.getTelefono())
                .addValue("cod_reserva", null, Types.OTHER)                 // UUID -> OTHER, se ignora en el SP
                .addValue("fecha_reserva", data.getFechaReserva(), Types.DATE)
                .addValue("hora_reserva",  data.getHoraReserva(),  Types.TIME) // asegurate que venga "HH:mm:00"
                .addValue("nro_restaurante", 1, Types.INTEGER)
                .addValue("nro_sucursal", data.getIdSucursal(), Types.INTEGER)
                .addValue("cod_zona", data.getCodZona(), Types.INTEGER)
                .addValue("cant_adultos", data.getCantAdultos(), Types.INTEGER)
                .addValue("cant_menores", data.getCantMenores(), Types.INTEGER)
                .addValue("costo_reserva", data.getCostoReserva(), Types.DECIMAL)
                .addValue("cancelada", 0, Types.BIT)
                .addValue("fecha_cancelacion", null, Types.DATE);

        Map<String, Object> out =
                jdbcCallFactory.executeWithOutputs("ins_cliente_reserva_sucursal", "dbo", params);

        @SuppressWarnings("unchecked")
        java.util.List<java.util.Map<String, Object>> rs =
                (java.util.List<java.util.Map<String, Object>>) out.get("#result-set-1");

        if (rs != null && !rs.isEmpty()) {
            Object v = rs.get(0).get("cod_reserva");     // nombre de columna del SELECT del SP
            return (v instanceof java.util.UUID) ? v.toString() : String.valueOf(v);
        }
        return null; // o lanzar excepción si preferís
    }
    public List<HorarioBean> getHorarios(SoliHorarioBean data) {
        SqlParameterSource params = new MapSqlParameterSource()
               .addValue("id_sucursal", data.getIdSucursal(), Types.INTEGER)
                .addValue("cant",data.getCantComensales(), Types.INTEGER)
                .addValue("cod_zona", data.getCodZona(), Types.INTEGER)
                .addValue("fecha",data.getFecha(), Types.DATE)
                .addValue("hora",data.getHora(), Types.TIME);
        return jdbcCallFactory.executeQuery("", "dbo", params, "", HorarioBean.class);
    }
    public RestauranteBean getRestuarantes(){
        return jdbcCallFactory.executeQuery("get_restaurantes", "dbo", "", .class)
    }

}
