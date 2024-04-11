import { Component, OnInit } from '@angular/core';
import { version } from '../../../package.json';

@Component({
	selector: 'app-system-version',
	templateUrl: './system-version.component.html',
	styleUrls: ['./system-version.component.scss']
})
export class SystemVersionComponent implements OnInit {
	public version: string = version;
	constructor() { }

	ngOnInit(): void {
	}

}
