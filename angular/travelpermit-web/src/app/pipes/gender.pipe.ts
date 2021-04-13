import { Pipe, PipeTransform } from '@angular/core';
import { BioGender } from 'src/api/enums';

@Pipe({
  name: 'gender'
})
export class GenderPipe implements PipeTransform {

  transform(value: BioGender | string): unknown {
		if (!value) {
			return '';
		}

    switch(value) {
			case BioGender.Male:
			case 'M':
				return 'Masculino';
			case BioGender.Female:
			case 'F':
				return 'Feminino';
			default: 
				return value;
		}
  }

}
