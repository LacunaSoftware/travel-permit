import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
	name: 'cpf'
})
export class CpfPipe implements PipeTransform {

	transform(value: string): unknown {
		if (typeof value === 'string' && /^\d{11}$/.exec(value)) {
			return value.substring(0, 3) + '.' + value.substring(3, 6) + '.' + value.substring(6, 9) + '-' + value.substring(9);
		}
		return value;
	}

}
