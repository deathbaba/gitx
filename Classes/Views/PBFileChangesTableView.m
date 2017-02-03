//
//  PBFileChangesTableView.m
//  GitX
//
//  Created by Pieter de Bie on 09-10-08.
//  Copyright 2008 Pieter de Bie. All rights reserved.
//

#import "PBFileChangesTableView.h"
#import "PBGitIndexController.h"

@implementation PBFileChangesTableView

#pragma mark NSTableView overrides

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	if(self.indexController) {
		NSPoint eventLocation = [self convertPoint: [theEvent locationInWindow] fromView: nil];
		NSInteger rowIndex = [self rowAtPoint:eventLocation];
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:TRUE];
		return [self.indexController menuForTable:self];
	}

	return nil;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
	return NSDragOperationEvery;
}

#pragma mark Event Handling

- (PBGitIndexController *) indexController
{
	return (PBGitIndexController *) self.delegate;
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
	//TODO: add & handle menu item for move to trash
	//TODO: use dynamic menu item names like in contextual menu
	if (menuItem.action == @selector(stageFilesAction:)) {
		menuItem.title = [self.class menuItemTitleForSelection:self.filesForStaging
									titleForMenuItemWithSingle:NSLocalizedString(@"Stage “%@”", @"Stage file menu item (single file with name)")
													  multiple:NSLocalizedString(@"Stage %i Files", @"Stage file menu item (multiple files with number)")
													   default:NSLocalizedString(@"Stage", @"Stage file menu item (empty selection)")];
		return self.hasFilesForStaging;
	}
	else if (menuItem.action == @selector(discardFilesAction:)) {
		menuItem.title = [self.class menuItemTitleForSelection:self.filesForStaging
									titleForMenuItemWithSingle:NSLocalizedString(@"Discard changes to “%@”…", @"Discard changes menu item (single file with name)")
													  multiple:NSLocalizedString(@"Discard changes to  %i Files…", @"Discard changes menu item (multiple files with number)")
													   default:NSLocalizedString(@"Discard…", @"Discard changes menu item (empty selection)")];
		menuItem.hidden = self.shouldTrashInsteadOfDiscard;
		return self.hasFilesForStaging && self.canDiscardAnyFile;
	}
	else if (menuItem.action == @selector(forceDiscardFilesAction:)) {
		menuItem.title = [self.class menuItemTitleForSelection:self.filesForStaging
									titleForMenuItemWithSingle:NSLocalizedString(@"Discard changes to “%@”", @"Force Discard changes menu item (single file with name)")
													  multiple:NSLocalizedString(@"Discard changes to  %i Files", @"Force Discard changes menu item (multiple files with number)")
													   default:NSLocalizedString(@"Discard", @"Force Discard changes menu item (empty selection)")];
		menuItem.hidden = self.shouldTrashInsteadOfDiscard;
		return self.hasFilesForStaging && self.canDiscardAnyFile;
	}
	else if (menuItem.action == @selector(trashFilesAction:)) {
		menuItem.title = [self.class menuItemTitleForSelection:self.filesForStaging
									titleForMenuItemWithSingle:NSLocalizedString(@"Move “%@” to Trash", @"Move to Trash menu item (single file with name)")
													  multiple:NSLocalizedString(@"Move %i Files to Trash", @"Move to Trash menu item (multiple files with number)")
													   default:NSLocalizedString(@"Move to Trash", @"Move to Trash menu item (empty selection)")];
		menuItem.hidden = !self.shouldTrashInsteadOfDiscard;
		return self.hasFilesForStaging && self.canDiscardAnyFile;
	}
	else if (menuItem.action == @selector(unstageFilesAction:)) {
		NSArray<PBChangedFile *> * filesForUnstaging = self.indexController.stagedFilesController.selectedObjects;
		menuItem.title = [self.class menuItemTitleForSelection:filesForUnstaging
									titleForMenuItemWithSingle:NSLocalizedString(@"Unstage “%@”", @"Unstage file menu item (single file with name)")
													  multiple:NSLocalizedString(@"Unstage %i Files", @"Unstage file menu item (multiple files with number)")
													   default:NSLocalizedString(@"Unstage", @"Unstage file menu item (empty selection)")];
		return filesForUnstaging.count > 0;
	}
	
	return [super validateMenuItem:menuItem];
}

+ (NSString *) menuItemTitleForSelection:(NSArray<PBChangedFile *> *)files
			  titleForMenuItemWithSingle:(NSString *)singleFormat
								multiple:(NSString *)multipleFormat
								 default:(NSString *)defaultString {
	
	NSUInteger numberOfFiles = files.count;
	
	if (numberOfFiles == 0) {
		return defaultString;
	}
	else if (numberOfFiles == 1) {
		return [NSString stringWithFormat:singleFormat, [PBGitIndexController getNameOfFirstFile:files]];
	}
	return [NSString stringWithFormat:multipleFormat, numberOfFiles];
}

- (BOOL) hasFilesForStaging {
	return self.numberOfSelectedFilesForStaging > 0;
}

- (NSUInteger) numberOfSelectedFilesForStaging{
	return self.filesForStaging.count;
}

- (NSArray<PBChangedFile *> *) filesForStaging {
	return self.indexController.unstagedFilesController.selectedObjects;
}

- (BOOL) canDiscardAnyFile {
	return [PBGitIndexController canDiscardAnyFileIn:self.filesForStaging];
}

- (BOOL) shouldTrashInsteadOfDiscard {
	return [PBGitIndexController shouldTrashInsteadOfDiscardAnyFileIn:self.filesForStaging];
}



#pragma mark IBActions

- (IBAction) stageFilesAction:(id)sender
{
	[self.indexController stageSelectedFiles];
}

- (IBAction) unstageFilesAction:(id)sender
{
	[self.indexController unstageSelectedFiles];
}

- (IBAction) discardFilesAction:(id) sender
{
	[self discardFiles:sender force:NO];
}

- (IBAction) forceDiscardFilesAction:(id)sender
{
	[self discardFiles:sender force:YES];
}

- (void) discardFiles:(id)sender force:(BOOL)force
{
	NSArray<PBChangedFile *> *selectedFiles = [sender representedObject];
	if (selectedFiles.count > 0) {
		[self.indexController discardChangesForFiles:selectedFiles force:force];
	}
}

- (IBAction) trashFilesAction:(id)sender
{
	NSArray<PBChangedFile *> *selectedFiles = [sender representedObject];
	[self.indexController moveToTrash:selectedFiles];
}



#pragma mark NSView overrides

-(BOOL)acceptsFirstResponder
{
    return [self numberOfRows] > 0;
}

-(NSView *)nextKeyView
{
    return [(PBGitIndexController*)[self delegate] nextKeyViewFor:self];
}

-(NSView *)previousKeyView
{
    return [(PBGitIndexController*)[self delegate] previousKeyViewFor:self];
}

@end
