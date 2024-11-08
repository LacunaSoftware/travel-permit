import { Pipe, PipeTransform } from '@angular/core';
import { TravelPermitTypes } from 'src/api/enums';

@Pipe({
	name: 'travelPermitType'
})
export class TravelPermitTypePipe implements PipeTransform {

	transform(value: TravelPermitTypes | string, ...args: unknown[]): unknown {
		if (!value) {
			return '';
		}
		switch (value) {
			case TravelPermitTypes.Domestic:
			case 'D':
				return 'Nacional';
			case TravelPermitTypes.International:
			case 'I':
				return 'Internacional';
			default:
				return value;
		}
	}

}
