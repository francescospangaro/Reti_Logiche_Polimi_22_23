# Progetto di Reti Logiche

Progetto di reti logiche, anno 2022/2023, prof Gianluca Palermo  
  
30/30 cum laude   
  
Il progetto consiste nella descrizione e specifica di un componente hardware che  
aspetta un segnale i_start alto per iniziare a leggere dall'ingresso i_w, allora inizierà  
a leggere da i_w una stringa di bit lunga 1<x<19, i primi 2 bit indicano su quale delle 4  
uscite, z0, z1, z2, z3, andare a scrivere il dato, i rimanenti bit indicano da quale indirizzo  
di memoria, implementata dal test bench, andare a leggere il dato.  
  
Una volta recuperato l'indirizzo da input, lo andremo a scrivere in o_mem_addr, un'uscita collegata  
al test bench che, al ciclo di clock successivo, ci farà trovare sull'ingresso i_mem_data, il dato  
salvato sull'indirizzo in o_mem_addr.  

Una volta trovato il dato, basta solo andare a scriverlo sull'uscita prima identificata,  
insieme allo scrivere su tutte le altre uscite il dato stampato nelle iterazioni precedenti (0 se mai utilizzate),
e alzare a 1 il segnale o_done.
  
Il segnale in ingresso i_rst serve a gestire un reset asincrono: il momento in cui il segnale è alto,  
tutte le uscite, i vecchi dati salvati, e i segnali interni al componente, devono essere settati a 0.  
