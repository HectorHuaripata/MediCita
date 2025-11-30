/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package medicita;
import UI.*;
/**
 *
 * @author Hector
 */
public class MediCita {
    /**
     * @param args the command line arguments
     */
    private static DataAccess da = new DataAccess();;
    
    public static void main(String args[]) {

        /* Create and display the form */
        java.awt.EventQueue.invokeLater(() -> new FrameMainMenu(da).setVisible(true));
    }
}
