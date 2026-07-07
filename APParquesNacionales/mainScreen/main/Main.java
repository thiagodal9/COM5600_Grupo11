package main;
import menu.*;

public class Main 
{
	public static void main(String[] args) 
	{
		Menu principal = new Menu();
		
		principal.mostrar();
		
		while( principal.continuar() )
		{
			principal.ingresarOpcion();
		}
		
		System.out.println("\n--Programa finalizado.--");
	}
}