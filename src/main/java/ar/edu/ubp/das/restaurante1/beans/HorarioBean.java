package ar.edu.ubp.das.restaurante1.beans;

import java.sql.Date;
import java.sql.Time;

public class HorarioBean {
    private Date fecha;
    private Time hora;

    public Date getFecha() {
        return fecha;
    }

    public void setFecha(Date fecha) {
        this.fecha = fecha;
    }

    public Time getHora() {
        return hora;
    }

    public void setHora(Time hora) {
        this.hora = hora;
    }
}
