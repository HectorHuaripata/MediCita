/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package medicita;
import java.sql.Connection;
import java.sql.DriverManager;
import oracle.jdbc.OracleDriver;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.Date;
import javax.swing.table.DefaultTableModel;
/**
 *
 * @author Hector
 */
public class DataAccess {
    public Connection crearConexion(){
        Connection con = null;
        try{
            DriverManager.registerDriver(new OracleDriver());
            con = DriverManager.getConnection(
                    "jdbc:oracle:thin:@localhost:1521/xepdb1","MEDICITA_DB_USR","Medicita");
            System.out.println("Conexion Exitosa.");
        }
        catch(SQLException e){
            System.out.println("Error al registrar el driver: "+e.getMessage());
        }
        return con;
    }

    public void listarPacientes(DefaultTableModel tblModel){
        String sql = "SELECT * FROM PACIENTE";
        Connection con;
        Statement stm;
        try{
            con = crearConexion();
            stm = con.createStatement();
            ResultSet rst = stm.executeQuery(sql);
            while( rst.next() ){
                int id = rst.getInt(1);
                String nombre = rst.getString(2);
                String apPaterno = rst.getString(3);
                String apMaterno = rst.getString(4);
                String dni = rst.getString(5);
                Date fecNacimiento = rst.getDate(6);
                //int sexo = rst.getInt(7);
                String sexo = rst.getInt(7) == 1? "Masculino" : "Femenino";
                String direccion = rst.getString(8);
                Long telefono = rst.getLong(9);
                String correo = rst.getString(10);
                
                ////
                
                //String tbData[] = { String.valueOf(id), nombre, apPaterno, apMaterno, dni, String.valueOf(fecNacimiento), String.valueOf(sexo), direccion, String.valueOf(telefono), correo};
                String tbData[] = { String.valueOf(id), nombre, apPaterno, apMaterno, dni, String.valueOf(fecNacimiento), sexo, direccion, String.valueOf(telefono), correo};
                tblModel.addRow(tbData);
            }
            con.close();
        }
        catch(SQLException e){
            System.out.println("Error al crea la sentencia: "+e.getMessage());
        }
    }
    
    public void listarMedicos(DefaultTableModel tblModel){
        String sql = "SELECT m.id_medico, m.nombres, m.apellido_paterno, m.apellido_materno, m.colegiatura, m.telefono, m.correo, e.nombre, s.nombre FROM MEDICO m JOIN ESPECIALIDAD e ON m.id_especialidad = e.id_especialidad JOIN SEDE s ON m.id_sede = s.id_sede";
        Connection con;
        Statement stm;
        try{
            con = crearConexion();
            stm = con.createStatement();
            ResultSet rst = stm.executeQuery(sql);
            while( rst.next() ){
                int id = rst.getInt(1);
                String nombre = rst.getString(2);
                String apPaterno = rst.getString(3);
                String apMaterno = rst.getString(4);
                int colegiatura = rst.getInt(5);
                Long telefono = rst.getLong(6);
                String correo = rst.getString(7);
                String id_especialidad = rst.getString(8);
                String id_sede = rst.getString(9);
                
                String tbData[] = {String.valueOf(id), nombre, apPaterno, apMaterno, String.valueOf(colegiatura), String.valueOf(telefono), correo, id_especialidad, id_sede};
                tblModel.addRow(tbData);
            }
            con.close();
        }
        catch(SQLException e){
            System.out.println("Error al crea la sentencia: "+e.getMessage());
        }
    }
    
    public void listarCitas(DefaultTableModel tblModel){
        String sql = "SELECT c.id_cita, e.nombre, c.fecha, c.hora, c.diagnostico, c.observaciones FROM CITA c JOIN ESTADO_CITA e ON c.id_estado = e.id_estado";
        Connection con;
        Statement stm;
        try{
            con = crearConexion();
            stm = con.createStatement();
            ResultSet rst = stm.executeQuery(sql);
            while( rst.next() ){
                int id = rst.getInt(1);
                String estado = rst.getString(2);
                Date fecha = rst.getDate(3);
                Timestamp hora = rst.getTimestamp(4);
                String diagnostico = rst.getString(5);
                String observaciones = rst.getString(6);
                
                String tbData[] = {String.valueOf(id), estado, String.valueOf(fecha), String.valueOf(hora), diagnostico, observaciones};
                tblModel.addRow(tbData);
            }
            con.close();
        }
        catch(SQLException e){
            System.out.println("Error al crea la sentencia: "+e.getMessage());
        }
    }
}
