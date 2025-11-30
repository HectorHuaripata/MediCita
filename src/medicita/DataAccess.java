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
                    "jdbc:oracle:thin:@192.168.1.4:1521/xepdb1","MEDICITA_DB_USR","Medicita");
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
}
