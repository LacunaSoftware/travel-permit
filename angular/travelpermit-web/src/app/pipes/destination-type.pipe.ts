import { Pipe, PipeTransform } from '@angular/core';
import { DestinationTypes } from 'src/api/enums';

@Pipe({
	name: 'destinationType'
})
export class DestinationTypePipe implements PipeTransform {

	transform(value: DestinationTypes | string, ...args: unknown[]): unknown {
		if (!value) {
			return '';
		}
		switch (value) {
			case DestinationTypes.AnyDestination:
			case 'AnyDestination':
				return 'Não especificado';
			case DestinationTypes.Specific:
			case 'Specific':
				return 'Específico';
			default:
				return value;
		}
	}

}
