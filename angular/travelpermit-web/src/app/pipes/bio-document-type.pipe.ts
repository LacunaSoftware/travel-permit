import { Pipe, PipeTransform } from '@angular/core';
import { BioDocumentType } from 'src/api/enums';

@Pipe({
	name: 'bioDocumentType'
})
export class BioDocumentTypePipe implements PipeTransform {


	transform(value: BioDocumentType | string): unknown {
		if (!value) {
			return '';
		}

		switch (value) {
			case BioDocumentType.IdCard:
			case 'I':
				return 'RG';
			case BioDocumentType.Passport:
			case 'P':
				return 'Passaporte';
			case BioDocumentType.ProfessionalCard:
			case 'T':
				return 'Carteira Profissional';
			case BioDocumentType.RNE:
			case 'E':
				return 'RNE';
			case BioDocumentType.ReservistCard:
			case 'R':
				return 'Carteira de Reservista';
			default:
				return value;
		}
	}

}
