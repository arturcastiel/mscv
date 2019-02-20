nameFile = 'start_spe.dat';

superFolder = strcat(pwd,'/start/');

command = ['cp ' superFolder nameFile ' ' pwd '/start.dat'];
system(command);
