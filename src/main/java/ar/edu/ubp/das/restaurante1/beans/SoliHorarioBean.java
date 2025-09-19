package ar.edu.ubp.das.restaurante1.beans;

import java.sql.Date;
import java.sql.Time;

public class SoliHorarioBean {
    private Date fecha;
    private Time hora;
    private int idSucursal;
    private int cantComensales;

    public int getIdSucursal() {
        return idSucursal;
    }

    public void setIdSucursal(int idSucursal) {
        this.idSucursal = idSucursal;
    }

    public int getCantComensales() {
        return cantComensales;
    }

    public void setCantComensales(int cantComensales) {
        this.cantComensales = cantComensales;
    }

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

