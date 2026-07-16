package menu;
import java.util.Scanner;

import app.*; 

public class Menu 
{
	private APPN app;
	private boolean estado;
	private boolean cont;
	private Scanner scan;

	public Menu() 
	{
		app = new APPN();
		estado = false;
		cont = true;
		scan = new Scanner(System.in);
	}
	
	public boolean continuar()
	{return cont;}
	
	public void mostrar()
	{
		System.out.println
		(
				"Operaciones Disponibles:\n"
				+ "1) Iniciar Sistema.\n"
				+ "2) Ingresar un nuevo parque.\n"
				+ "3) Modificar el nombre de un parque.\n"
				+ "4) Modificar la superficie de un parque.\n"
				+ "5) Borrar un parque.\n"
				+ "6) Ver parques.\n"
				+ "7) Ver tipos de parques.\n"
				+ "8) Ver ubicaciones de parques.\n"
				+ "9) Cerrar.\n"
		);
	}
	
	public void iniciarSistema()
	{
		app.crearConexion();
		estado = app.isActivo();
	}
	
	public void estado() 
	{
		System.out.println("Sistema activo: " + estado + "\n");
	}

	public void setEstado(boolean estado) {
		this.estado = estado;
	}

	public void ingresarOpcion()
	{
		int opcion;
		
		System.out.println("-Ingrese la opcion deseada: ");
		opcion = scan.nextInt();
		
		switch (opcion) 
		{
			case 1: 
				iniciarSistema();
			break;
			case 2: 
				nuevo();
			break;
			case 3: 
				modNombre();
			break;
			case 4: 
				modSuperficie();
			break;
			case 5: 
				baja();
			break;
			case 6: 
				verP();
			break;
			case 7: 
				verTP();
			break;
			case 8: 
				verPro();
			break;
			case 9: 
			{
				cerrar();
				cont = false;
			}
			break;
			default:
				System.out.println("--ERROR: opcion inexistente.--\n");
		}
	}
	
	private void nuevo()
	{
		String nombre, latitud, longitud;
		int ubicacion, superficie, tipo;
		
		if(estado)
		{
			if( scan.hasNextLine() )
				scan.nextLine();
			
			System.out.println("-Ingrese el nombre del parque: ");
			nombre = scan.nextLine();
			
			System.out.println("\n-Ingrese la ubicacion: ");
			ubicacion = scan.nextInt();
			
			if( scan.hasNextLine() )
				scan.nextLine();
			
			System.out.println("-Ingrese la latitud: ");
			latitud = scan.nextLine();
			
			System.out.println("-Ingrese la longitud: ");
			longitud = scan.nextLine();
			
			System.out.println("\n-Ingrese la superficie(en hectareas): ");
			superficie = scan.nextInt();
			
			System.out.println("\n-Ingrese el tipo: ");
			tipo = scan.nextInt();
			
			app.altaParque(nombre, ubicacion, latitud, longitud, superficie, tipo);
		}
		else
			System.out.println("--Aun no se ha iniciado el sistema.--\n");
	}
	
	private void modNombre()
	{
		String nombre;
		int parque;
		
		if(estado)
		{
			System.out.println("-Ingrese el ID del parque a modificar: ");
			parque = scan.nextInt();
			
			if( scan.hasNextLine() )
				scan.nextLine();
			
			System.out.println("\n-Ingrese el nuevo nombre: ");
			nombre = scan.nextLine();
			
			app.modificarNombreParque(parque, nombre);
		}
		else
			System.out.println("--Aun no se ha iniciado el sistema.--\n");
	}
	
	private void modSuperficie()
	{
		int parque, superficie;
		
		if(estado)
		{
			System.out.println("-Ingrese el ID del parque a modificar: ");
			parque = scan.nextInt();
			
			System.out.println("-Ingrese el nuevo valor de superficie(en hectareas): ");
			superficie = scan.nextInt();
			
			app.modificacionSuperficieParque(parque, superficie);
		}
		else
			System.out.println("--Aun no se ha iniciado el sistema.--\n");
	}
	
	private void baja()
	{
		int parque;
				
		if(estado)
		{
			System.out.println("-Ingrese el ID del parque a dar de baja: ");
			parque = scan.nextInt();
					
			app.bajaParque(parque);
		}
		else
		System.out.println("--Aun no se ha iniciado el sistema.--\n");
	}
	
	private void verP()
	{
		if(estado)
			app.verParques();
		else
			System.out.println("--Aun no se ha iniciado el sistema.--\n");
	}
	
	private void verTP()
	{
		if(estado)
			app.verTiposParque();
		else
			System.out.println("--Aun no se ha iniciado el sistema.--\n");
	}
	
	private void verPro()
	{
		if(estado)
			app.verProvincia();
		else
			System.out.println("--Aun no se ha iniciado el sistema.--\n");
	}
	
	private void cerrar()
	{
		scan.close();
		app.cerrarConexion();
	}
}
