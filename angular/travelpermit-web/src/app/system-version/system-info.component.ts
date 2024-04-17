import { Component, OnInit } from '@angular/core';
import { version } from '../../../package.json';

@Component({
	selector: 'app-system-info',
	templateUrl: './system-info.component.html',
	styleUrls: ['./system-info.component.scss']
})
export class SystemInfoComponent implements OnInit {
	public version: string = version;
	constructor() { }

	ngOnInit(): void {
	}

}
