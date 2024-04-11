import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { SystemVersionComponent } from './system-version/system-version.component';
import { HomeComponent } from './home/home.component';

const routes: Routes = [
	{ path: '', component: HomeComponent },
	{ path: 'system/info', component: SystemVersionComponent }
];

@NgModule({
	imports: [RouterModule.forRoot(routes)],
	exports: [RouterModule]
})
export class AppRoutingModule { }